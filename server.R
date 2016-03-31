
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(quanteda)
library(data.table)
library(stringi)

options(stringsAsFactors = FALSE)

# Load data

unig <- readLines("data/unigrams.txt")
stopg <- readLines("data/stopgrams.txt")
big <- fread("data/bigrams.txt")
trig <- fread("data/trig.txt", nrow=1500000)
quadg <- fread("data/quadg.txt", nrow=1500000)
fiveg <- fread("data/fiveg.txt")
sixg <- fread("data/sixg.txt")

setkey(big,ngram)
setkey(trig,ngram)
setkey(quadg,ngram)
setkey(fiveg,ngram)
setkey(sixg,ngram)


shinyServer(function(input, output) {

    datasetInput <- reactive({input$inText})
    
    output$outText <- renderText({
    
        in_raw <- datasetInput()
        
        in_clean <- tokenize(toLower(corpus(in_raw)),
                         removePunct = TRUE, 
                         removeNumbers = TRUE,
                         removeTwitter = TRUE,
                         removeHyphens = TRUE,
                         simplify = TRUE)
        
        final <- in_clean[length(in_clean)]
        
        if(!final %in% unig){in_clean[length(in_clean)] <- unig[agrepl(final, unig,max.distance=0.2)][1]}
        
        in_text <- in_clean[in_clean %in% unig]
        in_size <- length(in_text)
        in_mean <- in_text[!in_text %in% stopg]
        
        in_uni <- rev(in_text)[1]
        in_big <- paste(rev(in_text)[2:1],collapse=" ")
        in_trig <- paste(rev(in_text)[3:1],collapse=" ")
        in_quad <- paste(rev(in_text)[4:1],collapse=" ")
        in_five <- paste(rev(in_text)[5:1],collapse=" ")
        
        out_big <- big[in_uni]
        out_trig <- trig[in_big,nomatch=0]
        out_quad <- quadg[in_trig,nomatch=0]
        out_five <- fiveg[in_quad,nomatch=0]
        out_six <- sixg[in_five,nomatch=0]
        
        predictions <- rbind(out_six, out_five, out_quad, out_trig, out_big)
        predictions <- predictions[!predictions$pred %in% c(stopg,"who"),]
        answer <- predictions[1,pred]
        
        if(is.null(answer)){answer<-out_big[1,pred]}
        
        output <- paste(in_raw, answer, sep=" ")
        output
        
    })

})
