
# Word Wizard Text Prediction App
#
# https://drtimsloan.shinyapps.io/predictapp/
#
# UI code

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Word Wizard text prediction app"),

  # Sidebar layout for text input
  sidebarLayout(
      
    sidebarPanel(
      textInput("inText",
                  "Enter your text here:"),
      submitButton(text="Get prediction"),
      img(src='wizard.png')
      
    ),

    # Main tabbed layout
    mainPanel(
        tabsetPanel(
            tabPanel("Predictions",
                     br(),
                     "Welcome to the Word Wizard text prediction interface!",
                     br(),
                     "Please allow a few seconds for the app to initialise",
                     br(),
                     "When ready, a message will appear below:",
                     br(),br(),
                     h3("Primary prediction", style = "color:blue"),
                     br(),
                     strong(textOutput("outText")),
                     br(),
                     h3("Alternative words", style = "color:blue"),
                     br(),
                     textOutput("outText2"),
                     textOutput("outText3"),
                     textOutput("outText4")),
            tabPanel("About", 
                    br(),
                    "This application was designed for the Coursera Data Science Specialisation Capstone",
                    br(),
                    h3("Model construction", style="color:blue"),
                    p("The model is based around a",
                      span("Stupid Backoff", style = "color:red"),
                      "ngram model."),
                      "A collection of texts comprising over 4 million tweets, blogs and news articles were used.",
                      p("Steps taken for training the model included:",br(),
                      "- Using the Quanteda package in R to build tables of ngrams (adjacent words) in the 2 to 6 range",br(),
                      "- Selecting a dictionary of 20,000 words comprising 98% of the texts and filtering out unknown words",br(),
                      "- Storing the tables in 3 columns for the ngrams, predicted word and observed frequencies"),
                    h3("Algorithm", style="color:blue"),
                    p("When the application is initialised, the ngram tables are loaded into memory with the",
                      "data table package, using the function fread for quick loading. Ngram tables are indexed",
                      "to allow for binary searching - this means that entries can be searched through extremely",
                      "quickly, allowing over 10 million rows to be scanned in about 0.1s."),
                    p("Once a user enters text and presses the submit button, the following takes place:",br(),
                      "- Input text is cleaned up and converted into a series of ngrams from short to long",br(),
                      "- The final word entered is checked against the dictionary and corrected with fuzzy matching if necessary",br(),
                      "- Ngrams are then compared against the relevant tables and matches ranked from longer ngrams to shorter",br(),
                      "- Words in a 'stopword' list such as 'the', 'and' and 'by' are given lower ranks to ensure meaningful predictions",br(),
                      "The result is a fast reliable prediction, with autocorrection if necessary and up to 3 alternative matches."),
                    h3("Links", style="color:blue"),
                    a("Github repository",href="http://github.com/drtimsloan/predictapp"),br(),
                    a("RPubs presentation",href="http://rpubs.com/drtimsloan/wordwizard")
                    )
        )
    )
  )
))
