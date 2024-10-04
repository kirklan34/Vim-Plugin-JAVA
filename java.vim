" java.vim - Plugin básico para programar en Java

" Establece el archivo de tipo para Java
autocmd BufNewFile,BufRead *.java setlocal filetype=java

" Habilitar el autocompletado
setlocal omnifunc=JavaComplete
set completeopt=menuone,noinsert,noselect

" Función para autocompletar
function! JavaComplete(findstart, base)
    if a:findstart
        " Encuentra el inicio de la palabra para autocompletar
        let l:line = getline(line('.'))
        let l:col = col('.') - 1
        let l:start = match(l:line[:l:col], '\k*$')
        let l:word = l:line[l:start:]
        return [l:start, l:word]
    else
        " Completa la palabra basada en los archivos Java en el directorio
        let l:results = []
        for l:file in glob('*.java', 0, 1)
            let l:class_name = substitute(l:file, '\.java$', '', '')
            call add(l:results, l:class_name)
        endfor
        return l:results
    endif
endfunction

" Comando para ejecutar el programa Java
command! Run call CompileAndRun()

function! CompileAndRun()
    " Guarda el archivo actual
    write

    " Compila el archivo Java actual
    let l:filename = expand('%:r') " Obtiene el nombre del archivo sin extensión
    let l:output = system('javac ' . l:filename . '.java')
    
    if v:shell_error
        echohl Error | echom 'Error en la compilación: ' . l:output | echohl None
        return
    endif

    " Ejecuta el programa Java
    let l:output = system('java ' . l:filename)
    echohl WarningMsg | echom 'Salida: ' . l:output | echohl None
endfunction

" Mapeo de teclas para ejecutar el programa con Ctrl+r
nnoremap <C-r> :Run<CR>
set number
colorscheme industry
