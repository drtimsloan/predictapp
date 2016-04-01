
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
trig <- fread("data/trig.txt")
quadg <- fread("data/quadg.txt")
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
        
        if(!final %in% unig){
            correct <- unig[agrepl(final, unig,max.distance=0.2)][1]
            if(is.na(correct)){correct <- unig[agrepl(final, unig,max.distance=0.5)][1]}
            in_temp <- unlist(strsplit(in_raw, " "))
            in_clean[length(in_clean)] <- correct
            ifelse(length(in_temp)==1,in_raw <- correct,{
                in_raw <- paste(c(in_temp[1:(length(in_temp)-1)],correct),collapse=" ")
            })
        }
        
        in_text <- in_clean[in_clean %in% unig]
        in_size <- length(in_text)
        
        in_uni <- rev(in_text)[1]
        in_big <- paste(rev(in_text)[2:1],collapse=" ")
        in_trig <- paste(rev(in_text)[3:1],collapse=" ")
        in_quad <- paste(rev(in_text)[4:1],collapse=" ")
        in_five <- paste(rev(in_text)[5:1],collapse=" ")
        
        out_big <- big[in_uni]
        out_trig <- trig[in_big,nomatch=0]
        out_trig <- trig[in_big,nomatch=0]
        out_quad <- quadg[in_trig,nomatch=0]
        out_five <- fiveg[in_quad,nomatch=0]
        out_six <- sixg[in_five,nomatch=0]
        
        predictions <- rbind(out_six[!pred %in% stopg], out_six[pred %in% stopg],
                             out_five[!pred %in% stopg], out_five[pred %in% stopg],
                             out_quad[!pred %in% stopg], out_quad[pred %in% stopg],
                             out_trig[!pred %in% stopg], out_trig[pred %in% stopg],
                             out_big[!pred %in% stopg], out_big[pred %in% stopg])
        
        answer <- predictions[1,pred]
        
        if(is.null(answer)){answer<-"the"}
        if(is.na(answer)){answer<-"the"}
        
        output <- paste(in_raw, answer, sep=" ")
        output

    })

})
