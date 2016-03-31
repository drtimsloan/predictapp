
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Text prediction app"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("inText",
                  "Enter your text here:"),
      submitButton(text="Get prediction")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      textOutput("outText")
    )
  )
))
