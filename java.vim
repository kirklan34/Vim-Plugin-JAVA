" Plugin básico para programar en Java
"Version:1.1
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
        return l:start
    else
        " Completa la palabra basada en las clases de los archivos Java en el directorio
        let l:results = []
        
        " Completar nombres de clases en el directorio actual
        for l:file in glob('*.java', 0, 1)
            let l:class_name = substitute(l:file, '\.java$', '', '')
            call add(l:results, l:class_name)
        endfor

        " Completar palabras del archivo actual
        let l:lines = getline(1, '$')
        for l:line in l:lines
            for l:word in split(l:line, '\W\+')
                if l:word =~? '^' . a:base
                    call add(l:results, l:word)
                endif
            endfor
        endfor

        return uniq(sort(l:results))
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

" Opciones adicionales de Vim
set number  " Muestra los números de línea
colorscheme industry  " Cambia el esquema de colores

" ===========================================
" Autocompletado automático mientras escribes
" ===========================================

" Habilitar autocompletado automático después de escribir un cierto número de caracteres
autocmd InsertCharPre *.java call s:auto_complete()

" Función que activa el autocompletado automáticamente
function! s:auto_complete() abort
    " Verifica que el omnifunc esté activo y que el popup de menú no esté ya visible
    if &omnifunc !=# '' && !pumvisible()
        " Llama al omnifunc para mostrar el menú emergente
        call feedkeys("\<C-x>\<C-o>", 'n')
    endif
endfunction

" Crear carpeta y archivo Main.java en Linux y Windows con nombre de carpeta personalizado
function! CreateDirAndMainJava(dir_name)
  " Determinar el sistema operativo
  if has("win32") || has("win64")
    let dir_command = 'mkdir ' . a:dir_name
    let file_command = 'echo.> ' . a:dir_name . '\\Main.java'
  else
    let dir_command = 'mkdir -p ' . a:dir_name
    let file_command = 'touch ' . a:dir_name . '/Main.java'
  endif

  " Crear carpeta con el nombre especificado
  call system(dir_command)
  
  " Crear archivo Main.java solo si no existe
  if !filereadable(a:dir_name . '/Main.java')
    call system(file_command)
  endif

  " Abrir el archivo Main.java
  execute 'edit ' . a:dir_name . '/Main.java'
endfunction

" Asignar un comando para ejecutar la función con un argumento
command! -nargs=1 CreateDirMainJava call CreateDirAndMainJava(<f-args>)

" Mapea Ctrl+T para abrir una nueva terminal en Vim 8.0+
nnoremap <C-t> :term<CR>

set mouse=a
