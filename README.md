# Vim Java Plugin

## Descripción

Este es un **plugin básico para Vim** que añade soporte para programar en **Java**. El plugin incluye:
- **Autocompletado** de clases y palabras clave del archivo actual.
- Un **comando personalizado** para compilar y ejecutar programas Java.
- Mapeo de teclas para ejecutar el programa con `Ctrl + r`.

## Funcionalidades

- **Autocompletado automático** mientras escribes en archivos `.java`.
- **Compilación y ejecución de código Java** directamente desde Vim usando el comando `:Run`.
- Navegación y edición mejorada de archivos Java con Vim.
- NUEVOS comandos v1.1 : `:CreateDirMainJava <param: Dir Name>` Crea un directorio con un archivo Main.java
- NUEVOS comandos v1.1 : Teclas [CTR+t] = `:term`, abre una terminal en el editor
### Autocompletado
El plugin activa el autocompletado usando el omnifunc de Vim. A medida que escribes, te sugiere palabras clave, nombres de clases y métodos, basándose en los archivos `.java` en el directorio actual.

### Ejecución y Compilación
Con el comando `:Run`, puedes compilar y ejecutar el programa Java actual en Vim. Si hay errores de compilación, serán mostrados en la barra de mensajes.

## Instalación

1. Asegúrate de tener configurado Vim con soporte para **Vimscript**.
2. Guarda el plugin en tu configuración de Vim:
    - Copia el código del plugin en un archivo `.vim` (por ejemplo, `java_plugin.vim`).
    - Incluye este archivo en tu `.vimrc` o `init.vim` con la línea:

    ```vim
    source /ruta/a/tu/java_plugin.vim
    ```

3. Reinicia Vim.

## Uso

### Autocompletado Automático

El autocompletado se activa automáticamente mientras escribes. Puedes desactivar el autocompletado automático o modificar el comportamiento editando la función `JavaComplete`.

### Ejecución de Programas Java

Para compilar y ejecutar tu programa Java:
1. Abre el archivo `.java` en Vim.
2. Guarda el archivo.
3. Presiona `Ctrl + r` o ejecuta el comando `:Run` para compilar y ejecutar el archivo actual.
   
Si hay algún error de compilación, será mostrado en la barra de mensajes de Vim.

## Ejemplo de Uso

```java
public class Test {
    public static void main(String[] args) {
        int a = 2;
        int b = 3;
        int suma = a + b;
        System.out.println("La suma es = " + suma);
    }
}
