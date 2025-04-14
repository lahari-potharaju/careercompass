library(shiny)
library(shinythemes)
library(randomForest)
library(dplyr)
library(ggplot2)
library(DT)
library(corrplot)
library(plotly)

# Generate sample data
set.seed(123)
data <- data.frame(
  total_years_experience = round(runif(200, min = 0, max = 20)),
  skills_count = sample(0:50, 200, replace = TRUE),
  career_advance = as.factor(sample(0:1, 200, replace = TRUE, prob = c(0.3, 0.7)))  # Adjusted probabilities
)

# Random Forest model training
rf_model <- randomForest(career_advance ~ total_years_experience + skills_count, data = data)

# UI definition
ui <- navbarPage(
  theme = shinytheme("flatly"),
  title = "Career Advancement Predictor",
  
  tabPanel("Home",
           fluidPage(
             wellPanel(
               h3("Welcome to the Career Advancement Predictor!", icon("home")),
               p("Please fill out the form below to get started.")
             ),
             div(
               class = "well",
               h4("Your Details", icon("user")),
               textInput("name", "Name", placeholder = "Enter your full name here"),
               numericInput("age", "Age", value = NA, min = 18, max = 100, step = 1),
               selectInput("education", "Highest Level of Education", 
                           choices = c("High School" = "high_school",
                                       "Bachelor's" = "bachelors",
                                       "Master's" = "masters",
                                       "PhD" = "phd"),
                           selected = "bachelors"),
               selectInput("industry", "Industry",
                           choices = c("Technology" = "technology",
                                       "Finance" = "finance",
                                       "Healthcare" = "healthcare",
                                       "Education" = "education",
                                       "Manufacturing" = "manufacturing",
                                       "HR" = "hr"),
                           selected = "technology"),
               actionButton("submit", "Submit", icon("paper-plane"), class = "btn-primary"),
               tags$br(),
               tags$br(),
               textOutput("confirmationMessage")
             )
           )
  ),
  
  tabPanel("Predict",
           sidebarLayout(
             sidebarPanel(
               sliderInput("yearsExperience", "Total Years of Experience:", min = 0, max = 20, value = 10),
               sliderInput("skillsCount", "Number of Skills:", min = 0, max = 50, value = 25),
               actionButton("predict", "Predict Career Advancement", icon("chart-line")),
               selectInput("selectFeature", "Select Feature to Plot:",
                           choices = c("Total Years of Experience" = "total_years_experience",
                                       "Skills Count" = "skills_count"),
                           selected = "total_years_experience")
             ),
             mainPanel(
               tabsetPanel(type = "tabs",
                           tabPanel("Prediction Result", textOutput("result")),
                           tabPanel("Feature Plot", plotOutput("featurePlot")),
                           tabPanel("Data Table", DTOutput("dataTable")),
                           tabPanel("Statistical Summary", verbatimTextOutput("summaryStats")),
                           tabPanel("Correlation Plot", plotOutput("corPlot")),
                           tabPanel("Feature Importance", plotOutput("importancePlot"))
               )
             )
           )
  ),
  
  tabPanel("About",
           fluidPage(
             wellPanel("This app uses a Random Forest model to predict career advancement based on years of experience and number of skills.")
           )
  )
)

# Server logic
server <- function(input, output) {
  observeEvent(input$predict, {
    new_data <- data.frame(
      total_years_experience = input$yearsExperience,
      skills_count = input$skillsCount
    )
    prediction <- predict(rf_model, new_data, type = "class")
    output$result <- renderText({
      if (prediction == 1) "Prediction: Likely to advance in career" else "Prediction: Unlikely to advance in career"
    })
  })
  
  output$featurePlot <- renderPlot({
    req(input$selectFeature)
    selected_data <- data.frame(x = data[[input$selectFeature]], fill = data$career_advance)
    ggplot(selected_data, aes(x = x, fill = fill)) +
      geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
      labs(x = input$selectFeature, fill = "Career Advancement") +
      theme_minimal()
  })
  
  output$dataTable <- renderDT({
    datatable(data, options = list(pageLength = 10), filter = 'top')
  })
  
  output$summaryStats <- renderPrint({
    summary(data)
  })
  
  output$corPlot <- renderPlot({
    corr_data <- data[, sapply(data, is.numeric)]
    corr_mat <- cor(corr_data)
    corrplot(corr_mat, method = "circle")
  })
  
  output$importancePlot <- renderPlot({
    varImpPlot(rf_model, type = 2, main = "Variable Importance")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
