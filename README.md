# Career Compass

A Shiny web application that predicts career advancement likelihood using supervised machine learning. Built with R, it compares three models — Random Forest, Logistic Regression, and SVM — based on a professional's years of experience and number of skills.

## Features

- **Home** — Enter your name, age, and industry to get started
- **Predict** — Use sliders to set experience and skills, then get an instant prediction with confidence score
- **Model Comparison** — Side-by-side accuracy chart for all three ML models
- **Exploratory Views** — Feature distribution plots, data table, statistical summary, and correlation plot

## How to Run

**Requirements:** R 4.x with the following packages:

```r
install.packages(c("shiny", "shinythemes", "randomForest", "e1071",
                   "dplyr", "ggplot2", "DT", "corrplot", "plotly"))
```

**Launch the app:**

```r
shiny::runApp("careercompass.R")
```

Or open `careercompass.R` in RStudio and click **Run App**.

## Repository Structure

```
careercompass/
├── app.R                                      # Shiny entry point (sources careercompass.R)
├── careercompass.R                            # Main application — UI, server, ML models
├── data/
│   └── career_profiles.csv                   # LinkedIn-sourced career dataset
├── analysis/
│   └── career_advancement_analysis.Rmd       # Exploratory analysis and model write-up
└── docs/
    ├── career_advancement_report.docx         # Project report
    └── careercompass_presentation.pptx        # Presentation slides
```

## Models

| Model | Description |
|-------|-------------|
| Random Forest | Ensemble of decision trees; handles non-linear relationships |
| Logistic Regression | Baseline linear classifier; used for the live prediction |
| SVM (linear kernel) | Maximum-margin classifier |

Training data: 200 synthetic career profiles (balanced: 100 advance / 100 do not advance).

## Author

Lahari Potharaju
