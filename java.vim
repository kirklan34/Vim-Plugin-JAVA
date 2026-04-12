" ============================================================
"  JavaIDE.vim — Turns Vim into a JetBrains-like Java IDE
"  Version: 2.0
"  Author: kirklan34
" ============================================================

" ──────────────────────────────────────────────────────────
"  GUARD: prevent loading the plugin more than once per session
" ──────────────────────────────────────────────────────────
if exists('g:loaded_javaide')
  finish
endif
let g:loaded_javaide = 1

" ──────────────────────────────────────────────────────────
"  FILE TYPE DETECTION
"  Registers .java files and triggers the IDE setup on open
" ──────────────────────────────────────────────────────────
augroup JavaIDE_FileType
  autocmd!
  autocmd BufNewFile,BufRead *.java setlocal filetype=java
  autocmd FileType java call s:JavaIDESetup()
augroup END

" ──────────────────────────────────────────────────────────
"  CORE SETUP
"  Called once per Java buffer. Configures indentation,
"  folding, omnicompletion, keymaps, statusline, and
"  inserts a class template if the file is empty.
" ──────────────────────────────────────────────────────────
function! s:JavaIDESetup() abort
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal expandtab               " use spaces, not tabs (Java convention)
  setlocal autoindent
  setlocal smartindent
  setlocal textwidth=120           " soft wrap at 120 chars (Google Java Style)
  setlocal colorcolumn=121         " visual ruler at column 121
  setlocal signcolumn=yes          " always show the gutter (errors, warnings)
  setlocal foldmethod=syntax       " fold by { } blocks
  setlocal foldlevelstart=99       " start with all folds open
  setlocal matchpairs+=<:>         " match angle brackets for generics

  setlocal omnifunc=JavaCompleteFunc
  set completeopt=menuone,noinsert,noselect,popup

  call s:SetupMappings()
  call s:UpdateStatusLine()

  " Auto-insert class boilerplate when opening a new empty file
  if line('$') == 1 && getline(1) == ''
    call s:InsertClassTemplate()
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  GLOBAL VIM OPTIONS
"  Applied globally so the IDE feel extends beyond Java files
" ──────────────────────────────────────────────────────────
set number
set relativenumber          " relative line numbers for fast j/k navigation
set cursorline              " highlight the active line
set cursorcolumn            " highlight the active column
set mouse=a                 " enable mouse in all modes
set clipboard=unnamedplus   " sync with the OS clipboard
set hidden                  " allow switching buffers without saving
set splitright              " open vertical splits to the right
set splitbelow              " open horizontal splits below
set laststatus=2            " always show the status bar
set showtabline=2           " always show the tab bar
set termguicolors           " enable 24-bit RGB colors if the terminal supports it
set updatetime=300          " reduce delay for CursorHold events (used by diagnostics)
set shortmess+=c            " suppress completion menu messages in the command line
set pumheight=15            " limit the completion popup to 15 visible items
set wildmenu                " enable command-line completion menu
set wildmode=longest:full,full
set incsearch               " show search matches while typing
set hlsearch                " keep matches highlighted after search
set ignorecase              " case-insensitive search by default
set smartcase               " switch to case-sensitive when query has uppercase
set scrolloff=8             " keep 8 lines of context above and below the cursor
set sidescrolloff=8

" ──────────────────────────────────────────────────────────
"  DARCULA COLOR SCHEME
"  Approximates IntelliJ's Darcula theme using highlight groups.
"  Falls back to 'industry' if the terminal lacks true color support.
" ──────────────────────────────────────────────────────────
function! s:ApplyDarculaColors() abort
  if !has('gui_running') && !has('termguicolors')
    colorscheme industry
    return
  endif
  try
    colorscheme slate
  catch
    colorscheme industry
  endtry

  highlight Normal           guibg=#2B2B2B guifg=#A9B7C6
  highlight CursorLine       guibg=#323232 gui=NONE
  highlight CursorColumn     guibg=#2D2D2D
  highlight LineNr           guifg=#606366 guibg=#313335
  highlight CursorLineNr     guifg=#FFC66D guibg=#313335 gui=bold
  highlight ColorColumn      guibg=#3A3A3A
  highlight SignColumn       guibg=#313335
  highlight Visual           guibg=#214283
  highlight Search           guifg=#000000 guibg=#FFD700
  highlight IncSearch        guifg=#000000 guibg=#FF8C00
  highlight Pmenu            guibg=#3C3F41 guifg=#A9B7C6
  highlight PmenuSel         guibg=#4B6EAF guifg=#FFFFFF gui=bold
  highlight PmenuSbar        guibg=#3C3F41
  highlight PmenuThumb       guibg=#4B6EAF
  highlight StatusLine       guibg=#4B6EAF guifg=#FFFFFF gui=bold
  highlight StatusLineNC     guibg=#3C3F41 guifg=#808080
  highlight TabLine          guibg=#3C3F41 guifg=#808080
  highlight TabLineSel       guibg=#4B6EAF guifg=#FFFFFF gui=bold
  highlight TabLineFill      guibg=#2B2B2B
  highlight Comment          guifg=#808080 gui=italic
  highlight Keyword          guifg=#CC7832 gui=bold
  highlight String           guifg=#6A8759
  highlight Number           guifg=#6897BB
  highlight Type             guifg=#FFC66D
  highlight Function         guifg=#FFC66D
  highlight Identifier       guifg=#A9B7C6
  highlight Constant         guifg=#9876AA
  highlight Error            guifg=#FF0000 guibg=#3B0000
  highlight WarningMsg       guifg=#FFC66D
  highlight Todo             guifg=#A8C023 guibg=NONE gui=bold
  highlight MatchParen       guibg=#3B514D guifg=#FFFFFF gui=bold
  highlight Folded           guibg=#2B2B2B guifg=#606366
  highlight VertSplit        guifg=#4B6EAF guibg=#2B2B2B
  highlight Title            guifg=#4B6EAF gui=bold

  " Custom JavaIDE diagnostic highlight groups
  " Used by the statusline and sign column
  highlight JavaIDEError     guifg=#FF6B68 gui=undercurl
  highlight JavaIDEWarning   guifg=#FFC66D gui=undercurl
  highlight JavaIDEInfo      guifg=#6897BB
  highlight JavaIDEHint      guifg=#808080
endfunction

call s:ApplyDarculaColors()

" ──────────────────────────────────────────────────────────
"  STATUS LINE
"  Displays: git branch | filename | errors | warnings |
"            filetype | line:col | scroll% | java version
" ──────────────────────────────────────────────────────────
function! s:UpdateStatusLine() abort
  let l:branch   = s:GetGitBranch()
  let l:errors   = s:GetErrorCount()
  let l:warnings = s:GetWarningCount()

  let &statusline = ''
  let &statusline .= '%#StatusLine# '
  let &statusline .= (l:branch != '') ? ' ' . l:branch . '  ' : ''
  let &statusline .= '%f'
  let &statusline .= '%m'               " [+] when buffer has unsaved changes
  let &statusline .= '%r'               " [RO] when buffer is read-only
  let &statusline .= ' %='
  let &statusline .= (l:errors > 0)   ? '%#JavaIDEError# ✖ ' . l:errors . ' '   : ''
  let &statusline .= (l:warnings > 0) ? '%#JavaIDEWarning# ⚠ ' . l:warnings . ' ' : ''
  let &statusline .= '%#StatusLine# %{&filetype} '
  let &statusline .= '  %l:%c '
  let &statusline .= ' %p%% '
  let &statusline .= ' Java %{JavaIDEGetJavaVersion()} '
endfunction

" Cache the Java version so we don't shell out on every redraw
function! JavaIDEGetJavaVersion() abort
  if !exists('g:javaide_java_version')
    let l:ver   = system('java -version 2>&1')
    let l:match = matchstr(l:ver, '"\zs[^"]*\ze"')
    let g:javaide_java_version = (l:match != '') ? l:match : '?'
  endif
  return g:javaide_java_version
endfunction

" Returns the current git branch name, or empty string if not in a repo
function! s:GetGitBranch() abort
  if executable('git')
    let l:branch = system('git rev-parse --abbrev-ref HEAD 2>/dev/null')
    return substitute(l:branch, '\n', '', 'g')
  endif
  return ''
endfunction

" Count errors and warnings from the location list (populated after compile)
function! s:GetErrorCount() abort
  return len(filter(copy(getloclist(0)), 'v:val.type ==# "E"'))
endfunction

function! s:GetWarningCount() abort
  return len(filter(copy(getloclist(0)), 'v:val.type ==# "W"'))
endfunction

augroup JavaIDE_Status
  autocmd!
  autocmd BufEnter,WinEnter,InsertLeave *.java call s:UpdateStatusLine()
augroup END

" ──────────────────────────────────────────────────────────
"  OMNICOMPLETION
"  Completion sources (in priority order):
"    1. Java language keywords (including Java 17+ additions)
"    2. Standard library classes and common methods
"    3. Project classes (all .java files under the working dir)
"    4. Identifiers already present in the current buffer
" ──────────────────────────────────────────────────────────
let s:java_keywords = [
  \ 'abstract', 'assert', 'boolean', 'break', 'byte', 'case', 'catch', 'char',
  \ 'class', 'const', 'continue', 'default', 'do', 'double', 'else', 'enum',
  \ 'extends', 'final', 'finally', 'float', 'for', 'goto', 'if', 'implements',
  \ 'import', 'instanceof', 'int', 'interface', 'long', 'native', 'new',
  \ 'package', 'private', 'protected', 'public', 'record', 'return', 'sealed',
  \ 'short', 'static', 'strictfp', 'super', 'switch', 'synchronized', 'this',
  \ 'throw', 'throws', 'transient', 'try', 'var', 'void', 'volatile', 'while',
  \ 'permits', 'yield'
  \ ]

let s:java_stdlib = [
  \ 'String', 'Integer', 'Long', 'Double', 'Float', 'Boolean', 'Character',
  \ 'Byte', 'Short', 'Number', 'Object', 'System', 'Math', 'StringBuilder',
  \ 'StringBuffer', 'Arrays', 'Collections', 'ArrayList', 'LinkedList',
  \ 'HashMap', 'LinkedHashMap', 'TreeMap', 'HashSet', 'LinkedHashSet', 'TreeSet',
  \ 'List', 'Map', 'Set', 'Queue', 'Deque', 'Stack', 'Vector', 'Iterator',
  \ 'Optional', 'Stream', 'Collectors', 'Comparator', 'Comparable', 'Iterable',
  \ 'Runnable', 'Callable', 'Thread', 'Throwable', 'Exception', 'RuntimeException',
  \ 'NullPointerException', 'IllegalArgumentException', 'IllegalStateException',
  \ 'IndexOutOfBoundsException', 'UnsupportedOperationException', 'IOException',
  \ 'Scanner', 'PrintWriter', 'BufferedReader', 'FileReader', 'FileWriter',
  \ 'Path', 'Paths', 'Files', 'File', 'InputStream', 'OutputStream',
  \ 'BigInteger', 'BigDecimal', 'Random', 'UUID',
  \ 'Instant', 'LocalDate', 'LocalTime', 'LocalDateTime', 'Duration', 'Period',
  \ 'Pattern', 'Matcher',
  \ 'AtomicInteger', 'AtomicLong', 'AtomicBoolean',
  \ 'ExecutorService', 'Executors', 'Future', 'CompletableFuture',
  \ 'Function', 'BiFunction', 'Consumer', 'Supplier', 'Predicate',
  \ 'Objects', 'Class', 'Enum', 'Record', 'Interface',
  \ 'Override', 'Deprecated', 'SuppressWarnings', 'FunctionalInterface',
  \ 'System.out', 'System.err', 'System.in',
  \ 'println', 'print', 'printf', 'format',
  \ 'length', 'size', 'isEmpty', 'contains', 'get', 'put', 'add', 'remove',
  \ 'toString', 'equals', 'hashCode', 'compareTo', 'valueOf', 'parseInt',
  \ 'substring', 'charAt', 'indexOf', 'replace', 'split', 'trim', 'strip',
  \ 'toUpperCase', 'toLowerCase', 'startsWith', 'endsWith', 'matches',
  \ 'stream', 'filter', 'map', 'reduce', 'collect', 'forEach', 'sorted',
  \ 'findFirst', 'findAny', 'anyMatch', 'allMatch', 'noneMatch', 'count',
  \ 'orElse', 'orElseGet', 'orElseThrow', 'isPresent', 'ifPresent'
  \ ]

function! JavaCompleteFunc(findstart, base) abort
  if a:findstart
    " Walk left from the cursor to find the start of the current token
    let l:line  = getline('.')
    let l:col   = col('.') - 1
    let l:start = l:col
    while l:start > 0 && l:line[l:start - 1] =~# '\w'
      let l:start -= 1
    endwhile
    return l:start
  endif

  let l:results    = []
  let l:base_lower = tolower(a:base)

  " Source 1: language keywords
  for l:kw in s:java_keywords
    if tolower(l:kw) =~# '^' . l:base_lower
      call add(l:results, {'word': l:kw, 'menu': '[keyword]', 'kind': 'k'})
    endif
  endfor

  " Source 2: standard library
  for l:cls in s:java_stdlib
    if tolower(l:cls) =~# '^' . l:base_lower
      call add(l:results, {'word': l:cls, 'menu': '[java.stdlib]', 'kind': 't'})
    endif
  endfor

  " Source 3: classes found in the project (recursive glob)
  for l:file in glob('**/*.java', 0, 1)
    let l:cls = fnamemodify(l:file, ':t:r')
    if tolower(l:cls) =~# '^' . l:base_lower
      call add(l:results, {'word': l:cls, 'menu': '[project]', 'kind': 'c'})
    endif
  endfor

  " Source 4: words already in the current buffer (variables, method names, etc.)
  let l:seen = {}
  for l:line in getline(1, '$')
    for l:word in split(l:line, '\W\+')
      if l:word =~? '^' . a:base && len(l:word) > 1 && !has_key(l:seen, l:word)
        let l:seen[l:word] = 1
        call add(l:results, {'word': l:word, 'menu': '[buffer]', 'kind': 'v'})
      endif
    endfor
  endfor

  return l:results
endfunction

" Trigger omnicompletion automatically after typing 2+ word characters.
" Resets the counter when a non-word character is typed (spaces, operators, etc.)
augroup JavaIDE_Autocomplete
  autocmd!
  autocmd InsertCharPre *.java call s:SmartAutoComplete()
augroup END

let s:auto_complete_chars = 0
function! s:SmartAutoComplete() abort
  if v:char !~# '\w'
    let s:auto_complete_chars = 0
    return
  endif
  let s:auto_complete_chars += 1
  if s:auto_complete_chars >= 2 && &omnifunc !=# '' && !pumvisible()
    call feedkeys("\<C-x>\<C-o>", 'n')
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  SNIPPETS
"  Type a trigger word in insert mode and press Tab to expand.
"  If the word is not a known trigger, Tab inserts a real tab.
" ──────────────────────────────────────────────────────────
let s:snippets = {
  \ 'psvm':  "public static void main(String[] args) {\n    \n}",
  \ 'sout':  "System.out.println();",
  \ 'serr':  "System.err.println();",
  \ 'soutf': 'System.out.printf("", );',
  \ 'fori':  "for (int i = 0; i < ; i++) {\n    \n}",
  \ 'fore':  "for ( :  ) {\n    \n}",
  \ 'while': "while () {\n    \n}",
  \ 'ife':   "if () {\n    \n} else {\n    \n}",
  \ 'try':   "try {\n    \n} catch (Exception e) {\n    e.printStackTrace();\n}",
  \ 'tcf':   "try {\n    \n} catch (Exception e) {\n    e.printStackTrace();\n} finally {\n    \n}",
  \ 'prf':   "private final ",
  \ 'lst':   "List<> list = new ArrayList<>();",
  \ 'map':   "Map<, > map = new HashMap<>();",
  \ 'opt':   "Optional<> opt = Optional.ofNullable();",
  \ 'lmb':   "() -> ",
  \ 'str':   "Stream.of().filter().map().collect(Collectors.toList());",
  \ 'cls':   "public class  {\n    \n}",
  \ 'iface': "public interface  {\n    \n}",
  \ 'rec':   "public record (, ) {}",
  \ 'enum':  "public enum  {\n    ;\n}",
  \ 'annot': "@interface  {\n    \n}",
  \ 'test':  "@Test\npublic void () {\n    // Arrange\n    \n    // Act\n    \n    // Assert\n    \n}",
  \ 'log':   "private static final Logger log = LoggerFactory.getLogger(.class);",
  \ 'sw':    "switch () {\n    case :\n        break;\n    default:\n        break;\n}",
  \ }

function! JavaIDEExpandSnippet() abort
  let l:line  = getline('.')
  let l:col   = col('.') - 1
  let l:start = match(l:line[:l:col - 1], '\k*$')
  let l:word  = l:line[l:start : l:col - 1]

  if has_key(s:snippets, l:word)
    " Remove the trigger word and replace it with the expanded snippet
    let l:before = l:line[:l:start - 1]
    let l:after  = l:line[l:col :]
    call setline('.', l:before . l:after)
    call cursor('.', l:start + 1)

    let l:lines = split(s:snippets[l:word], '\n', 1)
    call append(line('.') - 1, l:lines)
    call cursor(line('.'), len(l:before) + 1)
    return ''
  endif

  " Not a known trigger — insert a literal tab character
  return "\<Tab>"
endfunction

" ──────────────────────────────────────────────────────────
"  COMPILE & RUN
"  JavaIDECompile: saves, runs javac from the file's directory,
"    parses the output into the location list, returns 1 on success.
"  JavaIDERun: calls compile first; on success, runs the class
"    in a split terminal using 'java -cp .' to avoid classpath issues
"    caused by Vim's working directory differing from the file's directory.
" ──────────────────────────────────────────────────────────
function! JavaIDECompile() abort
  write
  let l:file = expand('%:p')
  let l:dir  = expand('%:p:h')

  " Change to the file's directory before invoking javac so that
  " relative imports and multi-file projects resolve correctly.
  " Any .jar files found under the project root are added to the classpath.
  let l:jars = glob(l:dir . '/**/*.jar', 0, 1)
  let l:cp   = join(l:jars, ':')
  let l:cmd  = 'cd ' . shellescape(l:dir) . ' && javac '
        \ . (l:cp != '' ? '-cp ' . shellescape(l:cp) . ' ' : '')
        \ . shellescape(fnamemodify(l:file, ':t')) . ' 2>&1'

  let l:output = system(l:cmd)
  call s:ParseAndShowDiagnostics(l:output)

  if v:shell_error == 0
    echohl Title | echo ' Compiled successfully ' | echohl None
    return 1
  else
    echohl Error | echo ' Compilation failed — run :lopen to see errors ' | echohl None
    return 0
  endif
endfunction

function! JavaIDERun() abort
  if !JavaIDECompile()
    return
  endif
  let l:class = expand('%:r')
  let l:dir   = expand('%:p:h')

  " Use 'cd <dir> && java -cp .' to ensure the JVM finds the compiled .class
  " files regardless of where Vim was launched from.
  let l:cmd = 'cd ' . shellescape(l:dir) . ' && java -cp . ' . fnamemodify(l:class, ':t')

  if has('terminal')
    execute 'botright terminal ' . l:cmd
  elseif has('nvim')
    execute 'split | terminal ' . l:cmd
  else
    let l:out = system(l:cmd)
    echo l:out
  endif
endfunction

" Detect the build tool and run the test suite accordingly.
" Falls back to a message if neither Maven nor Gradle is found.
function! JavaIDERunTests() abort
  write
  let l:dir = expand('%:p:h')
  if filereadable(l:dir . '/../pom.xml') || filereadable('pom.xml')
    botright terminal mvn test
  elseif filereadable(l:dir . '/../build.gradle') || filereadable('build.gradle')
    botright terminal gradle test
  else
    echo 'No pom.xml or build.gradle found. Run tests manually.'
  endif
endfunction

" Full project build: prefers Maven, then Gradle.
function! JavaIDE_BuildProject() abort
  if filereadable('pom.xml')
    botright terminal mvn clean install
  elseif filereadable('build.gradle')
    botright terminal gradle build
  else
    echohl WarningMsg | echo 'No pom.xml or build.gradle found.' | echohl None
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  DIAGNOSTICS
"  Parses javac stderr output and populates the location list.
"  Format matched: Foo.java:10: error: some message
"  Opens :lopen automatically when errors or warnings exist.
" ──────────────────────────────────────────────────────────
function! s:ParseAndShowDiagnostics(output) abort
  call setloclist(0, [])
  let l:entries = []

  for l:line in split(a:output, '\n')
    let l:m = matchlist(l:line, '\(.\+\.java\):\(\d\+\): \(error\|warning\|note\): \(.*\)')
    if len(l:m) > 4
      let l:type = (l:m[3] ==# 'error') ? 'E' : (l:m[3] ==# 'warning') ? 'W' : 'I'
      call add(l:entries, {
        \ 'filename': l:m[1],
        \ 'lnum':     str2nr(l:m[2]),
        \ 'text':     l:m[4],
        \ 'type':     l:type
        \ })
    endif
  endfor

  if !empty(l:entries)
    call setloclist(0, l:entries)
    lopen
  else
    lclose
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  CLASS TEMPLATE
"  Inserted automatically when a new empty .java file is opened.
"  Infers the package from the directory structure (supports
"  standard Maven layout: src/main/java/<package>).
" ──────────────────────────────────────────────────────────
function! s:InsertClassTemplate() abort
  let l:class_name = expand('%:t:r')
  let l:pkg        = s:DetectPackage()
  let l:template   = []

  if l:pkg != ''
    call add(l:template, 'package ' . l:pkg . ';')
    call add(l:template, '')
  endif

  call extend(l:template, [
    \ '/**',
    \ ' * ' . l:class_name,
    \ ' */',
    \ 'public class ' . l:class_name . ' {',
    \ '',
    \ '    public static void main(String[] args) {',
    \ '        ',
    \ '    }',
    \ '',
    \ '}',
    \ ])

  call setline(1, l:template)
  call cursor(len(l:template) - 3, 9)
endfunction

" Infer the Java package from the file path.
" Handles Maven (src/main/java/) and generic (src/) layouts.
function! s:DetectPackage() abort
  let l:path = expand('%:p:h')

  let l:maven_pos = match(l:path, 'src/main/java/')
  if l:maven_pos >= 0
    let l:pkg_path = l:path[l:maven_pos + len('src/main/java/'):]
    return substitute(l:pkg_path, '/', '.', 'g')
  endif

  let l:src_pos = match(l:path, 'src/')
  if l:src_pos >= 0
    let l:pkg_path = l:path[l:src_pos + len('src/'):]
    return substitute(l:pkg_path, '/', '.', 'g')
  endif

  return ''
endfunction

" ──────────────────────────────────────────────────────────
"  FILE EXPLORER
"  Wraps Netrw's :Lexplore to toggle a project tree on the left.
"  Configured to tree-style listing with no banner (like IntelliJ's
"  Project panel).
" ──────────────────────────────────────────────────────────
function! JavaIDEToggleTree() abort
  if exists('t:javaide_tree_open') && t:javaide_tree_open
    execute 'Lexplore'
    let t:javaide_tree_open = 0
  else
    let g:netrw_liststyle    = 3   " tree listing mode
    let g:netrw_banner       = 0   " hide the Netrw banner
    let g:netrw_winsize      = 25  " 25% of the window width
    let g:netrw_browse_split = 4   " open files in the previous window
    execute 'Lexplore'
    let t:javaide_tree_open = 1
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  PROJECT SEARCH
"  FindInProject: grep across all .java files using :vimgrep.
"  FindClass: locate a .java file by partial class name.
"  Results appear in the quickfix window.
" ──────────────────────────────────────────────────────────
function! JavaIDEFindInProject() abort
  let l:pattern = input('Search in project: ')
  if l:pattern == ''
    return
  endif
  execute 'vimgrep /' . escape(l:pattern, '/') . '/gj **/*.java'
  copen
endfunction

function! JavaIDEFindClass() abort
  let l:pattern = input('Find class: ')
  if l:pattern == ''
    return
  endif
  let l:files = glob('**/*' . l:pattern . '*.java', 0, 1)
  if empty(l:files)
    echo 'No results found.'
    return
  endif
  let l:entries = map(l:files, "{'filename': v:val, 'text': fnamemodify(v:val, ':t:r')}")
  call setqflist(l:entries)
  copen
endfunction

" ──────────────────────────────────────────────────────────
"  REFACTORING
" ──────────────────────────────────────────────────────────

" Rename every occurrence of the word under the cursor in the current file.
" Uses \< \> word boundaries to avoid partial matches.
function! JavaIDERenameSymbol() abort
  let l:old = expand('<cword>')
  let l:new = input('Rename "' . l:old . '" to: ')
  if l:new == '' || l:new == l:old
    return
  endif
  execute '%s/\<' . escape(l:old, '/') . '\>/' . escape(l:new, '/') . '/gc'
endfunction

" Sort and deduplicate all import statements in the file.
" Preserves the rest of the file untouched.
function! JavaIDEOrganizeImports() abort
  let l:lines        = getline(1, '$')
  let l:imports      = filter(copy(l:lines), "v:val =~# '^import '")
  let l:sorted       = sort(uniq(copy(l:imports)))
  let l:first_import = -1
  let l:last_import  = -1

  for l:i in range(len(l:lines))
    if l:lines[l:i] =~# '^import '
      if l:first_import == -1
        let l:first_import = l:i + 1
      endif
      let l:last_import = l:i + 1
    endif
  endfor

  if l:first_import > 0
    execute l:first_import . ',' . l:last_import . 'delete _'
    call append(l:first_import - 1, l:sorted)
    echo 'Imports organized: ' . len(l:sorted) . ' statements'
  else
    echo 'No import statements found.'
  endif
endfunction

" Generate a public getter for the private field on the current line.
" Expects the line to match: private <Type> <fieldName>
function! JavaIDEAddGetter() abort
  let l:line = getline('.')
  let l:m    = matchlist(l:line, '\s*private\s*\(\w\+\)\s\+\(\w\+\)')
  if empty(l:m)
    echo 'Place the cursor on a private field declaration.'
    return
  endif
  let l:type   = l:m[1]
  let l:name   = l:m[2]
  let l:getter = 'get' . toupper(l:name[0]) . l:name[1:]
  call append(line('.') + 1, [
    \ '',
    \ '    public ' . l:type . ' ' . l:getter . '() {',
    \ '        return ' . l:name . ';',
    \ '    }'
    \ ])
  echo 'Generated: ' . l:getter . '()'
endfunction

" Generate a public setter for the private field on the current line.
function! JavaIDEAddSetter() abort
  let l:line = getline('.')
  let l:m    = matchlist(l:line, '\s*private\s*\(\w\+\)\s\+\(\w\+\)')
  if empty(l:m)
    echo 'Place the cursor on a private field declaration.'
    return
  endif
  let l:type   = l:m[1]
  let l:name   = l:m[2]
  let l:setter = 'set' . toupper(l:name[0]) . l:name[1:]
  call append(line('.') + 1, [
    \ '',
    \ '    public void ' . l:setter . '(' . l:type . ' ' . l:name . ') {',
    \ '        this.' . l:name . ' = ' . l:name . ';',
    \ '    }'
    \ ])
  echo 'Generated: ' . l:setter . '(' . l:type . ')'
endfunction

" Scan all private fields in the file and generate a toString() override.
" Inserts the method just before the closing brace of the class.
function! JavaIDEGenerateToString() abort
  let l:fields = []
  for l:line in getline(1, '$')
    let l:m = matchlist(l:line, '\s*private\s*\(\w\+\)\s\+\(\w\+\)\s*;')
    if !empty(l:m)
      call add(l:fields, l:m[2])
    endif
  endfor

  if empty(l:fields)
    echo 'No private fields found.'
    return
  endif

  let l:class_name = expand('%:t:r')
  let l:parts      = map(copy(l:fields), '"\"" . v:val . "=\" + " . v:val')
  let l:body       = '"' . l:class_name . '{" + ' . join(l:parts, ' + ", " + ') . ' + "}"'

  " Find the last closing brace and insert above it
  let l:last = line('$')
  while getline(l:last) !~# '}'
    let l:last -= 1
  endwhile

  call append(l:last - 1, [
    \ '',
    \ '    @Override',
    \ '    public String toString() {',
    \ '        return ' . l:body . ';',
    \ '    }'
    \ ])
  echo 'toString() generated with ' . len(l:fields) . ' fields.'
endfunction

" ──────────────────────────────────────────────────────────
"  PROJECT SCAFFOLDING
"  NewMavenProject: runs mvn archetype:generate with the quickstart
"    archetype and opens App.java on success.
"  NewGradleProject: creates the standard src layout, writes
"    build.gradle with JUnit 5, and opens Main.java.
" ──────────────────────────────────────────────────────────
function! JavaIDECreateMavenProject(name) abort
  let l:cmd = 'mvn archetype:generate'
        \ . ' -DgroupId=com.project'
        \ . ' -DartifactId=' . a:name
        \ . ' -DarchetypeArtifactId=maven-archetype-quickstart'
        \ . ' -DinteractiveMode=false'
  echo 'Creating Maven project: ' . a:name . ' ...'
  call system(l:cmd)
  if v:shell_error == 0
    execute 'edit ' . a:name . '/src/main/java/com/project/App.java'
    echo 'Maven project created successfully.'
  else
    echohl Error | echo 'Failed to create Maven project. Is mvn installed?' | echohl None
  endif
endfunction

function! JavaIDECreateGradleProject(name) abort
  call system('mkdir -p ' . a:name . '/src/main/java')
  call system('mkdir -p ' . a:name . '/src/test/java')
  call writefile([
    \ "plugins {",
    \ "    id 'java'",
    \ "}",
    \ "",
    \ "repositories {",
    \ "    mavenCentral()",
    \ "}",
    \ "",
    \ "dependencies {",
    \ "    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'",
    \ "}",
    \ "",
    \ "test {",
    \ "    useJUnitPlatform()",
    \ "}"
    \ ], a:name . '/build.gradle')
  execute 'edit ' . a:name . '/src/main/java/Main.java'
  echo 'Gradle project created successfully.'
endfunction

" ──────────────────────────────────────────────────────────
"  JAVADOC GENERATOR
"  Detects whether the cursor is on a method or class declaration
"  and inserts an appropriate /** ... */ block above it.
"  For methods: generates @param for each parameter, @return
"    if the return type is not void, and a @throws placeholder.
"  For classes: generates @author, @version, and @since.
" ──────────────────────────────────────────────────────────
function! JavaIDEAddJavadoc() abort
  let l:line      = getline('.')
  let l:is_method = l:line =~# '\s*\(public\|private\|protected\).*(.*).*{'
  let l:is_class  = l:line =~# '\s*\(public\|private\|protected\).*class '
  let l:doc       = ['/**']

  if l:is_method
    call add(l:doc, ' * ')
    let l:params = matchstr(l:line, '(\zs[^)]*\ze)')
    for l:param in split(l:params, ',')
      let l:pname = matchstr(trim(l:param), '\w\+$')
      if l:pname != ''
        call add(l:doc, ' * @param ' . l:pname . ' ')
      endif
    endfor
    let l:ret = matchstr(l:line, '\(public\|private\|protected\)\s\+\zs\w\+\ze\s')
    if l:ret !=# 'void'
      call add(l:doc, ' * @return ')
    endif
    call add(l:doc, ' * @throws ')
  else
    call add(l:doc, ' * ')
    if l:is_class
      call add(l:doc, ' * @author ')
      call add(l:doc, ' * @version 1.0')
      call add(l:doc, ' * @since ' . strftime('%Y-%m-%d'))
    endif
  endif

  call add(l:doc, ' */')
  call append(line('.') - 1, l:doc)
  call cursor(line('.') - len(l:doc) + 1, 4)
endfunction

" ──────────────────────────────────────────────────────────
"  FILE & DIRECTORY CREATION
" ──────────────────────────────────────────────────────────

" Create a directory and an empty Main.java inside it, then open the file.
" Handles both Unix and Windows path conventions.
function! JavaIDECreateDirAndFile(dir_name) abort
  if has('win32') || has('win64')
    call system('mkdir ' . a:dir_name)
    if !filereadable(a:dir_name . '\Main.java')
      call system('echo.> ' . a:dir_name . '\Main.java')
    endif
  else
    call system('mkdir -p ' . a:dir_name)
    if !filereadable(a:dir_name . '/Main.java')
      call system('touch ' . a:dir_name . '/Main.java')
    endif
  endif
  execute 'edit ' . a:dir_name . '/Main.java'
endfunction

" Open a new buffer for a Java class with the given name
function! JavaIDENewClass(class_name) abort
  execute 'edit ' . a:class_name . '.java'
endfunction

" Open a new buffer for a Java interface and insert a minimal skeleton
function! JavaIDENewInterface(name) abort
  execute 'edit ' . a:name . '.java'
  call setline(1, [
    \ 'public interface ' . a:name . ' {',
    \ '',
    \ '}'
    \ ])
endfunction

" ──────────────────────────────────────────────────────────
"  DIAGNOSTICS PANEL TOGGLE
" ──────────────────────────────────────────────────────────
function! JavaIDEToggleDiagnostics() abort
  if exists('g:javaide_diagnostics_open') && g:javaide_diagnostics_open
    lclose
    let g:javaide_diagnostics_open = 0
  else
    lopen
    let g:javaide_diagnostics_open = 1
  endif
endfunction

" ──────────────────────────────────────────────────────────
"  KEY MAPPINGS
"  All mappings are buffer-local (<buffer>) so they only
"  activate inside .java files and don't pollute other filetypes.
" ──────────────────────────────────────────────────────────
function! s:SetupMappings() abort
  " Build & run
  nnoremap <buffer> <F5>        :call JavaIDERun()<CR>
  nnoremap <buffer> <F6>        :call JavaIDECompile()<CR>
  nnoremap <buffer> <F7>        :call JavaIDERunTests()<CR>
  nnoremap <buffer> <F8>        :call JavaIDE_BuildProject()<CR>

  " Tab expands snippets in insert mode; falls back to a literal tab
  inoremap <buffer> <expr><Tab> JavaIDEExpandSnippet()

  " Refactoring
  nnoremap <buffer> <leader>rn  :call JavaIDERenameSymbol()<CR>
  nnoremap <buffer> <leader>oi  :call JavaIDEOrganizeImports()<CR>
  nnoremap <buffer> <leader>gg  :call JavaIDEAddGetter()<CR>
  nnoremap <buffer> <leader>gs  :call JavaIDEAddSetter()<CR>
  nnoremap <buffer> <leader>ts  :call JavaIDEGenerateToString()<CR>
  nnoremap <buffer> <leader>jd  :call JavaIDEAddJavadoc()<CR>

  " Project navigation
  nnoremap <buffer> <leader>ff  :call JavaIDEFindInProject()<CR>
  nnoremap <buffer> <leader>fc  :call JavaIDEFindClass()<CR>
  nnoremap <buffer> gd          :execute 'vimgrep /\<' . expand('<cword>') . '\>/gj **/*.java' <bar> copen<CR>

  " Diagnostics — ]e / [e jump between errors like IntelliJ's F2
  nnoremap <buffer> <leader>d   :call JavaIDEToggleDiagnostics()<CR>
  nnoremap <buffer> ]e          :lnext<CR>
  nnoremap <buffer> [e          :lprev<CR>

  " Terminal — Ctrl+T and Ctrl+` both open a split terminal
  nnoremap <buffer> <C-t>       :botright terminal<CR>
  nnoremap <buffer> <C-`>       :botright terminal<CR>

  " File explorer toggle
  nnoremap <buffer> <leader>e   :call JavaIDEToggleTree()<CR>

  " Keep compatibility with the original Ctrl+R mapping from v1.x
  nnoremap <buffer> <C-r>       :call JavaIDERun()<CR>

  " Code folding
  nnoremap <buffer> za          za
  nnoremap <buffer> zR          zR   " unfold everything
  nnoremap <buffer> zM          zM   " fold everything

  " Window splitting
  nnoremap <buffer> <leader>sv  :vsplit<CR>
  nnoremap <buffer> <leader>sh  :split<CR>

  " Move between splits with Alt+hjkl
  nnoremap <buffer> <A-h>       <C-w>h
  nnoremap <buffer> <A-l>       <C-w>l
  nnoremap <buffer> <A-j>       <C-w>j
  nnoremap <buffer> <A-k>       <C-w>k

  " Close any open quickfix / location list panels
  nnoremap <buffer> <Esc>       :lclose<bar>cclose<CR>
endfunction

" Global mappings — available in any file, not just Java
nnoremap <leader>mn  :call JavaIDECreateMavenProject(input('Maven project name: '))<CR>
nnoremap <leader>gn  :call JavaIDECreateGradleProject(input('Gradle project name: '))<CR>
nnoremap <leader>nc  :call JavaIDENewClass(input('Class name: '))<CR>
nnoremap <leader>ni  :call JavaIDENewInterface(input('Interface name: '))<CR>

" ──────────────────────────────────────────────────────────
"  COMMANDS
"  Expose all major functions as Ex commands for discoverability
"  and so users can invoke them from the command line or scripts.
" ──────────────────────────────────────────────────────────
command! Run                        call JavaIDERun()
command! Compile                    call JavaIDECompile()
command! Test                       call JavaIDERunTests()
command! Build                      call JavaIDE_BuildProject()
command! Tree                       call JavaIDEToggleTree()
command! FindInProject              call JavaIDEFindInProject()
command! FindClass                  call JavaIDEFindClass()
command! RenameSymbol               call JavaIDERenameSymbol()
command! OrganizeImports            call JavaIDEOrganizeImports()
command! AddGetter                  call JavaIDEAddGetter()
command! AddSetter                  call JavaIDEAddSetter()
command! GenerateToString           call JavaIDEGenerateToString()
command! AddJavadoc                 call JavaIDEAddJavadoc()
command! Diagnostics                call JavaIDEToggleDiagnostics()
command! -nargs=1 NewClass          call JavaIDENewClass(<f-args>)
command! -nargs=1 NewInterface      call JavaIDENewInterface(<f-args>)
command! -nargs=1 NewMavenProject   call JavaIDECreateMavenProject(<f-args>)
command! -nargs=1 NewGradleProject  call JavaIDECreateGradleProject(<f-args>)
command! -nargs=1 CreateDirMainJava call JavaIDECreateDirAndFile(<f-args>)

" ──────────────────────────────────────────────────────────
"  EXTRA SYNTAX HIGHLIGHTING
"  Adds IDE-style visual cues on top of Vim's built-in Java syntax:
"    - TODO/FIXME/etc. keywords explicitly declared for visibility
"    - Annotations (@Override, @NotNull, custom ones) in Constant color
"    - System.out.print* highlighted in a distinct italic green
" ──────────────────────────────────────────────────────────
augroup JavaIDE_ExtraHighlight
  autocmd!
  autocmd FileType java syntax keyword javaTodo    TODO FIXME HACK NOTE XXX BUG contained
  autocmd FileType java syntax match  javaAnnot   '@\w\+' containedin=ALL
  autocmd FileType java highlight link javaAnnot  Constant
  autocmd FileType java syntax match  javaSout    'System\.out\.print\(ln\|f\)\?'
  autocmd FileType java highlight     javaSout    guifg=#6A8759 gui=italic
augroup END

" ──────────────────────────────────────────────────────────
"  WELCOME MESSAGE
"  Shown once on startup when Vim is opened with no file arguments.
"  Reminds the user of the most important keybindings.
" ──────────────────────────────────────────────────────────
function! s:WelcomeMessage() abort
  if argc() == 0
    echo ''
    echohl Title
    echo '  JavaIDE v2.0  —  Vim as a JetBrains IDE  '
    echohl None
    echo ''
    echo '  F5  Run            F6  Compile'
    echo '  F7  Run tests      F8  Build project'
    echo '  <leader>e  Tree    <leader>ff  Find in project'
    echo '  Tab  Snippets      <leader>rn  Rename symbol'
    echo ''
    echohl Comment
    echo '  All commands available via :help javaide'
    echohl None
  endif
endfunction

augroup JavaIDE_Welcome
  autocmd!
  autocmd VimEnter * call s:WelcomeMessage()
augroup END

" ── END OF JavaIDE.vim ────────────────────────────────────
