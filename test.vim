" Test para el plugin básico de Java

" =========================================================
" 1. Test para la función de autocompletado
" =========================================================

function! Test_JavaComplete()
    " Crear un buffer temporal para probar
    enew
    setlocal filetype=java

    " Escribir una clase Java en el buffer
    call setline(1, [
                \ 'public class test {',
                \ '    public static void main(String[] args) {',
                \ '        int a = 1;',
                \ '        int b = 2;',
                \ '        int suma = a + b;',
                \ '        System.out.println("Suma = " + suma);',
                \ '    }',
                \ '}'
                \ ])

    " Simular la autocompletación: debería sugerir "Test"
    let l:complete_results = JavaComplete(0, 't')

    " Verificar si la clase "Test" está en los resultados
    call assert_equal(['test'], l:complete_results)
    echom "Test_JavaComplete pasó"

    " Limpiar el buffer temporal
    bdelete!
endfunction

" =========================================================
" 2. Test para compilar y ejecutar
" =========================================================

function! Test_CompileAndRun()
    " Crear un archivo Java de prueba
    enew
    setlocal filetype=java

    " Escribir el código Java
    call setline(1, [
                \ 'public class test {',
                \ '    public static void main(String[] args) {',
                \ '        System.out.println("Test ejecutado correctamente");',
                \ '    }',
                \ '}'
                \ ])

    " Guardar el archivo en el disco para probar compilación y ejecución
    write test.java

    " Ejecutar la función de compilación
    call CompileAndRun()

    " Verificar si el archivo se compila correctamente
    if !v:shell_error
        echom "Compilación exitosa"
    else
        echom "Error en la compilación"
    endif

    " Limpiar el archivo de prueba
    call delete('test.java')
endfunction

" =========================================================
" 3. Test para verificar el mapeo de teclas (Ctrl + r)
" =========================================================

function! Test_KeyMapping()
    " Comprobar que <C-r> está mapeado a la función correcta
    let l:mapped = maparg('<C-r>', 'n')
    call assert_equal(':Run<CR>', l:mapped)
    echom "Test_KeyMapping pasó"
endfunction

" =========================================================
" Ejecutar los tests
" =========================================================

call Test_JavaComplete()
call Test_CompileAndRun()
call Test_KeyMapping()

