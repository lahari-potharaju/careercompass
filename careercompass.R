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
#split and train data
index <- sample(1:nrow(data), 0.7 * nrow(data))
train_data <- data[index, ]
test_data <- data[-index, ]


# Random Forest
rf_model <- randomForest(career_advance ~ ., data = train_data)
rf_pred <- predict(rf_model, test_data)
rf_acc <- mean(rf_pred == test_data$career_advance)
# Logistic Regression
log_model <- glm(career_advance ~ ., data = train_data, family = "binomial")
log_prob <- predict(log_model, test_data, type = "response")
log_pred <- factor(ifelse(log_prob > 0.5, 1, 0), levels = levels(test_data$career_advance))
log_acc <- mean(log_pred == test_data$career_advance)
# SVM
svm_model <- svm(career_advance ~ ., data = train_data, kernel = "linear")
svm_pred <- predict(svm_model, test_data)
svm_acc <- mean(svm_pred == test_data$career_advance)
#output
server <- function(input, output) {

  output$modelAccuracy <- renderPrint({
    cat("Model Accuracy Comparison:\n")
    cat("Random Forest:       ", round(rf_acc * 100, 2), "%\n")
    cat("Logistic Regression: ", round(log_acc * 100, 2), "%\n")
    cat("SVM:                 ", round(svm_acc * 100, 2), "%\n")
  })
  
}

# UI definition
ui <- navbarPage(
  theme = shinytheme("flatly"),
  title = "Career Compass",

  tabPanel("Home",
           fluidPage(
             wellPanel(
               h3("Welcome to the Career Compass", icon("home")),
               p("Please fill out the form below to get started.")
             ),
             div(
               class = "well",
               h4("Your Details", icon("user")),
               textInput("name", "Name", placeholder = "Enter your full name here"),
               numericInput("age", "Age", value = NA, min = 18, max = 100, step = 1),
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
                           tabPanel("Correlation Plot", plotOutput("corPlot"))
               )
             )
           )
  ),

  tabPanel("About",
           fluidPage(
             wellPanel("This app uses a Logistic Regression model to predict career advancement based on years of experience and number of skills.")
           )
  )
)

server <- function(input, output) {
  # Balanced sample data creation
  set.seed(123)
  data <- data.frame(
    total_years_experience = round(runif(200, 0, 20)),
    skills_count = sample(0:50, 200, replace = TRUE),
    career_advance = as.factor(rep(c(0,1), each = 100))  # Balanced: 100 of each
  )

  # Logistic regression model
  log_model <- glm(career_advance ~ ., data = data, family = "binomial")

  observeEvent(input$predict, {
    new_data <- data.frame(
      total_years_experience = input$yearsExperience,
      skills_count = input$skillsCount
    )
    pred_prob <- predict(log_model, new_data, type = "response")
    pred_class <- ifelse(pred_prob > 0.5, "Prediction: Likely to advance in career", "Prediction: Unlikely to advance in career")

    output$result <- renderText({
      paste0(pred_class, " (Confidence: ", round(pred_prob * 100, 1), "%)")
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
}

shinyApp(ui = ui, server = server)
