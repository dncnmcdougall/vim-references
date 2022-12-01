if exists('g:loaded_references') 
  finish
endif
let g:loaded_references = 1

if !exists('g:references#library') 
    let g:references#library='~/library.bib'
endif

if !exists('g:references#fzf') 
    let g:references#fzf=0
endif

if !exists('g:references#telescope') 
    let g:references#telescope=1
endif

function s:c(b)
    let t = type(a:b)
    if l:t == 0 " number
        return ''.a:b
    elseif l:t == 1 " string
        return "'".a:b."'"
    elseif l:t == 6 " boolean
        if a:b
            return 'true'
        else
            return 'false'
        endif
    elseif t == 7 " null
        return 'nil'
    endif
    return 'nil'
endfunction

function! references#bibTexSource()
    let l:list = ListBibTexLibrary()
    if empty(l:list)
        let l:list = ListBibTexLibrary()
    endif
    return l:list
endfunction

function! s:launch(prompt, title, author)

    if !filereadable(expand(g:references#library))
        echoerr 'Could not find library file: '.g:references#library
        return
    end

    if g:references#fzf
        if a:title && a:author 
            call fzf#run(fzf#wrap('references',{"source": references#bibTexSource(), 'sink':funcref('s:fzfCiteTitleAuthorSink') }))
        elseif a:title
            call fzf#run(fzf#wrap('references',{"source": references#bibTexSource(), 'sink':funcref('s:fzfCiteTitleSink') }))
        else 
            call fzf#run(fzf#wrap('references',{"source": references#bibTexSource(), 'sink':funcref('s:fzfCiteSink') }))
        endif
    elseif g:references#telescope
        execute "lua require('references').picker(nil, ".s:c(a:prompt).", ".s:c(a:title).", ".s:c(a:author).")"
    else
        echoerr "No search command was specified."
    endif
endfunction

command! -nargs=0 Cite      call s:launch('Cite', v:false, v:false)
command! -nargs=0 TCite     call s:launch('TCite', v:true, v:false)
command! -nargs=0 TACite    call s:launch('TACite', v:true, v:true)
command! -nargs=0 Reference call s:launch('Reference', v:true, v:true)

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

endif

