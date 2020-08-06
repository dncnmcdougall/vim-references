if exists('g:loaded_references') 
  finish
endif
let g:loaded_references = 1

if !exists('g:references#library') 
    let g:references#library='~/library.bib'
endif
