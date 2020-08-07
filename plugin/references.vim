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

    function! s:fzfCiteSink(line)
        call InsertReferenceAtCursor(a:line, v:false, v:false)
    endfunction

    function! s:fzfCiteTitleSink(line)
        call InsertReferenceAtCursor(a:line, v:true, v:false)
    endfunction

    function! s:fzfCiteTitleAuthorSink(line)
        call InsertReferenceAtCursor(a:line, v:true, v:true)
    endfunction

    function! s:fzfSource()
        let l:list = ListBibTexLibrary()
        if empty(l:list)
            let l:list = ListBibTexLibrary()
        endif
        return l:list
    endfunction

    command! -nargs=0 Cite call fzf#run(fzf#wrap('references',{"source": s:fzfSource(), 'sink':funcref('s:fzfCiteSink') }))
    command! -nargs=0 TCite call fzf#run(fzf#wrap('references',{"source": s:fzfSource(), 'sink':funcref('s:fzfCiteTitleSink') }))
    command! -nargs=0 TACite call fzf#run(fzf#wrap('references',{"source": s:fzfSource(), 'sink':funcref('s:fzfCiteTitleAuthorSink') }))
    command! -nargs=0 Reference call fzf#run(fzf#wrap('references',{"source": s:fzfSource(), 'sink':funcref('s:fzfCiteTitleAuthorSink') }))
endif

