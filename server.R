
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(tidyr)
library(quanteda)
library(data.table)
library(stringi)

options(stringsAsFactors = FALSE)

# Load data

# unig <- readLines("/home/tim/Documents/RProjects/NLP/ngrams/unigrams.txt")
# stopg <- readLines("/home/tim/Documents/RProjects/NLP/ngrams/stopgrams.txt")
# big <- fread("/home/tim/Documents/RProjects/NLP/ngrams/bigrams.txt")
# trig <- fread("/home/tim/Documents/RProjects/NLP/ngrams/trig.txt")
# quadg <- fread("/home/tim/Documents/RProjects/NLP/ngrams/quadg.txt")
# fiveg <- fread("/home/tim/Documents/RProjects/NLP/ngrams/fiveg.txt")
# sixg <- fread("/home/tim/Documents/RProjects/NLP/ngrams/sixg.txt")
# ideag <- fread("/home/tim/Documents/RProjects/NLP/ngrams/ideagrams.txt")

load("data/unig.RData")
load("data/stopg.RData")
load("data/big.RData")
load("data/trig.RData")
load("data/quadg.RData")
load("data/fiveg.RData")
load("data/sixg.RData")
load("data/ideag.RData")

shinyServer(function(input, output) {

    datasetInput <- eventReactive(input$action, {input$inText})
    
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
        
        
        in_uni <- paste(c(rev(in_text)[1],""),collapse=" ")
        in_big <- paste(c(rev(in_text)[2:1],""),collapse=" ")
        in_trig <- paste(c(rev(in_text)[3:1],""),collapse=" ")
        in_quad <- paste(c(rev(in_text)[4:1],""),collapse=" ")
        in_five <- paste(c(rev(in_text)[5:1],""),collapse=" ")
        
        
#         in_idea <- ideag[(ideag$one %in% in_mean) &
#                              (ideag$two %in% in_mean) &
#                              (ideag$three %in% in_mean) &
#                              (!ideag$four %in% in_mean),]
#         
#         test <- ideag[((ideag$one %in% in_mean) | (ideag$two %in% in_mean)) &
#                           ((ideag$two %in% in_mean) | (ideag$three %in% in_mean)) &
#                           ((ideag$one %in% in_mean) | (ideag$three %in% in_mean)) &
#                           (!ideag$four %in% in_mean),]
        
        out_big <- big[stri_startswith_fixed(big$ngram, in_uni)]
        out_trig <- trig[stri_startswith_fixed(trig$ngram, in_big)]
        out_quad <- quadg[stri_startswith_fixed(quadg$ngram, in_trig)]
        out_five <- fiveg[stri_startswith_fixed(fiveg$ngram, in_quad)]
        out_six <- sixg[stri_startswith_fixed(sixg$ngram, in_five)]
        
        
        predictions <- rbind(out_six, out_five, out_quad, out_trig, out_big)
        predictions$ngram <- sapply(predictions$ngram, function(x) {
            temp <- unlist(strsplit(x, " "))
            temp[length(temp)]})
        predictions <- predictions[!predictions$ngram %in% c(stopg,"who"),]
        # predictions <-  summarise(group_by(predictions, ngram), freq = sum(freq)) %>%
        #                 arrange(desc(freq))
        answer <- as.character(predictions[1,ngram])
        
        if(is.null(answer)){answer<-strsplit(out_big[1,ngram],split=" ")[[1]][2]}
        
        output <- paste(in_raw, answer, sep=" ")
        output
        
    })

})
