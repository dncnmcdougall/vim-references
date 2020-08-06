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

    function! s:fzfSink(line)
        call InsertReferenceAtCursor(a:line)
    endfunction

    function! s:fzfSource()
        let l:list = ListBibTexLibrary()
        if empty(l:list)
            let l:list = ListBibTexLibrary()
        endif
        return l:list
    endfunction

    command! -nargs=0 References call fzf#run(fzf#wrap('references',{"source": s:fzfSource(), 'sink':funcref('s:fzfSink') }))
endif

