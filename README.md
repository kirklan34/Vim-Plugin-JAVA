<div align="center">

# ☕ JavaIDE — Vim Plugin

**Convierte Vim en un JetBrains. Sin rodeos.**

[![Version](https://img.shields.io/badge/version-2.0-blue?style=flat-square)](https://github.com/kirklan34/Vim-Plugin-JAVA)
[![Vim](https://img.shields.io/badge/Vim-8.0%2B-green?style=flat-square&logo=vim)](https://www.vim.org)
[![License](https://img.shields.io/badge/license-GPL--3.0-orange?style=flat-square)](LICENSE)
[![Java](https://img.shields.io/badge/Java-8%2B-red?style=flat-square&logo=openjdk)](https://openjdk.org)
[![Vim Scripts](https://img.shields.io/badge/Vim%20Scripts-script__id%3D6139-lightgrey?style=flat-square)](https://www.vim.org/scripts/script.php?script_id=6139)

---

*¿Para qué pagar IntelliJ si tienes teclado y determinación?*

[Instalación](#-instalación) · [Características](#-características) · [Comandos](#-comandos-y-atajos) · [Snippets](#-snippets) · [Contribuir](#-contribuir)

</div>

---

## ¿Qué es esto?

**JavaIDE** es un plugin para Vim que transforma tu editor de texto favorito en un entorno de desarrollo Java completo. Autocompletado inteligente, compilación integrada, diagnósticos visuales, snippets, generación de código, temas oscuros, soporte para Maven y Gradle, y mucho más — todo desde Vim, todo en VimScript.

Empezó como un plugin simple para compilar y ejecutar `.java`. Ahora quiere ser IntelliJ.

---

## ✨ Características

### 🔵 Edición inteligente
- **Autocompletado** con keywords Java completas (incluyendo `var`, `record`, `sealed`, `permits` de Java 17+), stdlib (~100 clases), clases del proyecto actual y palabras del buffer
- Se activa automáticamente tras 2 caracteres sin interrumpir el flujo de escritura
- **Snippets** expandibles con `Tab` (`psvm`, `sout`, `fori`, `fore`, `try`, `lst`, `map`, `opt`, `lmb`, y más)
- **Plegado de código** por bloques de sintaxis (clases, métodos, lambdas)
- Resaltado de sintaxis extendido: anotaciones, `System.out.println`, TODOs/FIXMEs

### 🔴 Compilación y ejecución
- `F5` — Compilar **y** ejecutar en terminal integrada
- `F6` — Solo compilar
- `F7` — Ejecutar tests (JUnit con Maven/Gradle automáticamente detectado)
- `F8` — Build completo del proyecto (`mvn clean install` o `gradle build`)
- Los errores de `javac` se **parsean automáticamente** y aparecen en un panel de diagnósticos navegable

### 🟡 Refactoring
- Renombrar símbolo en todo el archivo (`<leader>rn`)
- Organizar e importar imports duplicados (`<leader>oi`)
- Generar getter y setter desde un campo `private` (`<leader>gg` / `<leader>gs`)
- Generar `toString()` automáticamente con todos los campos (`<leader>ts`)
- Insertar JavaDoc para métodos y clases (`<leader>jd`)

### 🟢 Navegación del proyecto
- Árbol de archivos lateral estilo Project Explorer (`<leader>e`)
- Buscar texto en todos los `.java` del proyecto (`<leader>ff`)
- Buscar clase por nombre (`<leader>fc`)
- Ir a definición de símbolo (`gd`)

### ⚪ Experiencia visual
- **Tema Darcula** integrado: colores oscuros idénticos a IntelliJ Darcula
- **Barra de estado** con rama git, errores/warnings, versión de Java y posición
- Números de línea relativos (navegación por saltos como JetBrains)
- Resaltado de línea y columna actual
- Columna de signos para diagnósticos (como el gutter de errores)

---

## 📦 Instalación

### Requisitos previos

| Herramienta | Versión mínima | Obligatorio |
|-------------|---------------|-------------|
| Vim | 8.0+ | ✅ Sí |
| Java JDK | 8+ | ✅ Sí |
| Git | cualquiera | ⚡ Recomendado |
| Maven o Gradle | cualquiera | ⚡ Para proyectos |

### Instalación manual

**1. Descargar el plugin:**
```bash
# Clonar el repositorio
git clone https://github.com/kirklan34/Vim-Plugin-JAVA.git
```

**2. Copiar el archivo:**
```bash
# Linux / macOS
cp Vim-Plugin-JAVA/java.vim ~/.vim/plugin/java.vim

# Windows (PowerShell)
Copy-Item Vim-Plugin-JAVA\java.vim $HOME\vimfiles\plugin\java.vim
```

**3. Añadir a tu `.vimrc`:**
```vim
" Opción A: usando el directorio plugin/ (recomendado, automático)
" Nada que hacer si lo pusiste en ~/.vim/plugin/

" Opción B: cargarlo manualmente
source ~/.vim/plugin/java.vim
```

**4. Reiniciar Vim.** Listo.

### Con un gestor de plugins

<details>
<summary><b>vim-plug</b></summary>

```vim
call plug#begin()
Plug 'kirklan34/Vim-Plugin-JAVA'
call plug#end()
```
Luego ejecuta `:PlugInstall`
</details>

<details>
<summary><b>Vundle</b></summary>

```vim
Plugin 'kirklan34/Vim-Plugin-JAVA'
```
Luego ejecuta `:PluginInstall`
</details>

<details>
<summary><b>pathogen</b></summary>

```bash
cd ~/.vim/bundle
git clone https://github.com/kirklan34/Vim-Plugin-JAVA.git
```
</details>

---

## ⌨️ Comandos y Atajos

### Teclas de función

| Tecla | Acción |
|-------|--------|
| `F5` | Compilar y ejecutar en terminal integrada |
| `F6` | Compilar (mostrar errores en panel) |
| `F7` | Ejecutar tests (JUnit / Maven / Gradle) |
| `F8` | Build completo del proyecto |

### Atajos con `<leader>` (por defecto `\`)

| Atajo | Acción |
|-------|--------|
| `<leader>e` | Abrir/cerrar árbol de archivos |
| `<leader>ff` | Buscar texto en el proyecto |
| `<leader>fc` | Buscar clase por nombre |
| `<leader>rn` | Renombrar símbolo bajo el cursor |
| `<leader>oi` | Organizar imports |
| `<leader>gg` | Generar getter del campo actual |
| `<leader>gs` | Generar setter del campo actual |
| `<leader>ts` | Generar `toString()` |
| `<leader>jd` | Insertar JavaDoc |
| `<leader>d` | Abrir/cerrar panel de diagnósticos |
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>mn` | Crear proyecto Maven (pide nombre) |
| `<leader>gn` | Crear proyecto Gradle (pide nombre) |
| `<leader>nc` | Nueva clase Java (pide nombre) |
| `<leader>ni` | Nuevo interface Java (pide nombre) |

### Navegación

| Atajo | Acción |
|-------|--------|
| `]e` | Ir al siguiente error/warning |
| `[e` | Ir al error/warning anterior |
| `gd` | Ir a la definición del símbolo |
| `Alt+h/j/k/l` | Moverse entre paneles/splits |
| `Ctrl+t` o `` Ctrl+` `` | Abrir terminal integrada |
| `za` | Plegar/desplegar bloque |
| `zM` / `zR` | Plegar/desplegar todo |

### Comandos `:Command`

```vim
:Run                      " Compilar y ejecutar
:Compile                  " Solo compilar
:Test                     " Ejecutar tests
:Build                    " Build completo del proyecto
:Tree                     " Toggle árbol de archivos
:FindInProject            " Buscar en todos los .java
:FindClass                " Buscar clase por nombre
:RenameSymbol             " Renombrar símbolo
:OrganizeImports          " Organizar imports
:AddGetter                " Generar getter
:AddSetter                " Generar setter
:GenerateToString         " Generar toString()
:AddJavadoc               " Insertar JavaDoc
:Diagnostics              " Toggle panel de errores
:NewClass <nombre>        " Nueva clase Java
:NewInterface <nombre>    " Nuevo interface Java
:NewMavenProject <nombre> " Crear proyecto Maven
:NewGradleProject <nombre>" Crear proyecto Gradle
:CreateDirMainJava <dir>  " Crear carpeta con Main.java
```

---

## 🧩 Snippets

Escribe el trigger y pulsa `Tab` para expandir:

| Trigger | Expande en |
|---------|-----------|
| `psvm` | `public static void main(String[] args) { }` |
| `sout` | `System.out.println();` |
| `serr` | `System.err.println();` |
| `soutf` | `System.out.printf("", );` |
| `fori` | Bucle `for` con índice |
| `fore` | Bucle `for-each` |
| `while` | Bucle `while` |
| `ife` | `if/else` |
| `try` | Bloque `try/catch` |
| `tcf` | Bloque `try/catch/finally` |
| `lst` | `List<> list = new ArrayList<>()` |
| `map` | `Map<,> map = new HashMap<>()` |
| `opt` | `Optional<> opt = Optional.ofNullable()` |
| `lmb` | Lambda `() ->` |
| `str` | Cadena de Stream completa |
| `cls` | Declaración de clase |
| `iface` | Declaración de interface |
| `rec` | Declaración de record (Java 16+) |
| `enum` | Declaración de enum |
| `test` | Método de test con `@Test` |
| `log` | Logger con SLF4J |
| `sw` | Bloque `switch` |
| `prf` | `private final` |

---

## 🚀 Ejemplos de uso

### Compilar y ejecutar con un keypress
```java
// Abre tu archivo .java, pulsa F5
public class HolaMundo {
    public static void main(String[] args) {
        System.out.println("Vim manda");
    }
}
// → Compila, ejecuta y muestra la salida en terminal integrada
```

### Generar getter/setter automático
```java
// Coloca el cursor en esta línea:
private String nombre;
// Pulsa <leader>gg → genera:
public String getNombre() {
    return nombre;
}
// Pulsa <leader>gs → genera:
public void setNombre(String nombre) {
    this.nombre = nombre;
}
```

### Snippets en acción
```
// Escribe: fore<Tab>
// Resultado:
for ( :  ) {
    
}

// Escribe: test<Tab>
// Resultado:
@Test
public void () {
    // Arrange
    
    // Act
    
    // Assert
    
}
```

### Crear un proyecto Maven desde Vim
```vim
" Pulsa <leader>mn o ejecuta:
:NewMavenProject miApp
" Crea la estructura completa de Maven y abre App.java
```

---

## 🛠️ Configuración avanzada

Puedes personalizar el comportamiento añadiendo esto en tu `.vimrc` **antes** de cargar el plugin:

```vim
" Cambiar el número de caracteres para activar autocompletado (por defecto: 2)
let g:javaide_autocomplete_chars = 3

" Desactivar el tema Darcula (usar tu propio colorscheme)
let g:javaide_no_theme = 1

" Desactivar los números relativos
let g:javaide_no_relativenumber = 1

" Desactivar la plantilla automática de clase nueva
let g:javaide_no_template = 1

" Cambiar el ancho del árbol de archivos (por defecto: 25)
let g:netrw_winsize = 30
```

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Si tienes ideas para mejorar el plugin:

1. Haz fork del repositorio
2. Crea una rama: `git checkout -b feature/mi-mejora`
3. Commitea tus cambios: `git commit -m 'Add: mi mejora'`
4. Push a la rama: `git push origin feature/mi-mejora`
5. Abre un Pull Request

### Ideas para contribuir

- Soporte para Language Server Protocol (LSP) con `jdtls`
- Integración con `coc.nvim` o `nvim-lspconfig`
- Soporte para Neovim con Lua
- Integración con debugger (`vimspector`)
- Más snippets (Spring Boot, Jakarta EE, etc.)
- Tests automatizados del plugin

---

## 📋 Historial de versiones

| Versión | Cambios |
|---------|---------|
| **2.0** | Tema Darcula, snippets, refactoring, diagnósticos parseados, Maven/Gradle, generación de código, barra de estado con git |
| **1.1** | Comando `CreateDirMainJava`, terminal con `Ctrl+T`, compatibilidad Windows/Linux |
| **1.0** | Autocompletado básico, compilación y ejecución con `:Run`, mapeo `Ctrl+R` |

---

## 📄 Licencia

Distribuido bajo la licencia **GPL-3.0**. Ver [LICENSE](LICENSE) para más detalles.

---

<div align="center">

Hecho con ☕ y demasiadas horas en la terminal.

**[kirklan34](https://github.com/kirklan34)** · [Ver en Vim Scripts](https://www.vim.org/scripts/script.php?script_id=6139) · [Reportar un bug](https://github.com/kirklan34/Vim-Plugin-JAVA/issues)

</div>
