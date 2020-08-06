if exists('g:loaded_references') 
  finish
endif
let g:loaded_references = 1

if !exists('g:references#library') 
    let g:references#library='~/library.bib'
endif

if !exists('g:references#fzf') 
    let g:references#fzf=1
endif

if g:references#fzf
    command! -nargs=0 References call fzf#run(fzf#wrap('references',{"source": ListBibTexLibrary(), 'sink':function('InsertReferenceAtCursor') }))
endif

