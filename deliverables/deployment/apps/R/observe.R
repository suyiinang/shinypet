#' Target variable selection,
#' Data splitting,
#' Distribution plot
#'
#' @param id, character used to specify namespace, see \code{shiny::\link[shiny]{NS}}
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#' 

observeUI <- function(id){
  fluidPage(
    titlePanel('Observe variables'),
    tags$style(
      type = 'text/css', 
      '.bg-orange {background-color: #FF5A5F!important; }'
    ),
    fluidRow(
      infoBoxOutput(NS(id,'variableBox'), width = 3),
      infoBoxOutput(NS(id,'obBox'), width = 3),
      infoBoxOutput(NS(id,'factorsBox'),width = 3),
      infoBoxOutput(NS(id,'numericBox'), width = 3)
    ),
    fluidRow(
      h3('Summary of factor variables'),
      column(12,
          DT::dataTableOutput(NS(id,'categorical')))),
    fluidRow(
      h3('Summary of numerical variables'),
      column(10,
          DT::dataTableOutput(NS(id,'numeric')))
    )
  )
}

observeServer <- function(id, final_listings){
  moduleServer(id, function(input, output, session){
    output$variableBox <- renderInfoBox({
      infoBox(
        'Variables',
        value = tags$p(paste0(length(final_listings)),style = "font-size: 200%;"),
        icon = icon('info'),
        color = 'orange',
        fill = TRUE
      )
    })
    
    output$obBox <- renderInfoBox({
      infoBox(
        'Observations',
        value = tags$p(paste0(nrow(final_listings)), style = "font-size: 200%;"),
        icon = icon('list'),
        color = 'orange',
        fill = TRUE
      )
    })    
    
    output$factorsBox <- renderInfoBox({
      infoBox(
        'Factor variables',
        value = tags$p(paste0(length(which(sapply(final_listings, is.factor)==TRUE))),style = "font-size: 200%;"),
        icon = icon('chart-pie'),
        color = 'orange',
        fill = TRUE
      )
    })
    
    
    output$numericBox <- renderInfoBox({
      infoBox(
        'Numerical variables',
        value = tags$p(paste0(length(which(sapply(final_listings, is.numeric)==TRUE))),style = "font-size: 200%;"),
        icon = icon('chart-line'),
        color = 'orange',
        fill = TRUE
      )
    })
    
    output$numeric <- DT::renderDataTable({
      
      skimDf <- final_listings %>%
        skim_without_charts()
      
      sum_n <-if ("numeric" %in% skimDf$skim_type){
        skimDf %>%
          yank('numeric') %>%
          select('skim_variable','n_missing','complete_rate',
                 'mean','sd','p0','p50','p100') %>%
          arrange(-n_missing) %>%
          mutate_if(is.numeric, round, digit = 2)}
      
      DT::datatable(sum_n, filter = 'top', 
                    options=list(pageLength = 5, 
                                 autoWidth=TRUE))
    })
    
    output$categorical <- DT::renderDataTable({
      
      skimDf <- final_listings %>%
        skim_without_charts()
      
      sum_f <-if ("factor" %in% skimDf$skim_type){
        skimDf %>% 
          yank("factor") %>% 
          arrange(-n_missing) %>%
          mutate_if(is.numeric, round, digit = 2)}
      
      DT::datatable(sum_f, filter = 'top', options=list(pageLength = 5, autoWidth=TRUE))
    })
  })
}

