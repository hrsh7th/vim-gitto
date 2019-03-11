let s:sdir = expand('<sfile>:p:h:h')

let s:U = {}

"
" common
"

function! s:U.autoload(fname)
  if !exists('*' . a:fname)
    let s:file = a:fname
    let s:file = substitute(s:file, '#', '/', 'g')
    let s:file = substitute(s:file, '/[^/]*$', '.vim', 'g')
    execute printf('source %s/%s', s:sdir, s:file)
  endif
endfunction

" run_in_dir
function! s:U.run_in_dir(dir, fn)
  let s:cwd = getcwd()
  try
    execute printf('lcd %s', a:dir)
    let s:return = a:fn()
  finally
    execute printf('lcd %s', s:cwd)
  endtry
  return s:return
endfunction

function! s:U.relative(path, ...)
  return s:U.run_in_dir(get(a:000, 0, getcwd()), { -> fnamemodify(a:path, ':.')})
endfunction

" choose yes/no
function! s:U.yes_or_no(msg)
  let s:choose = input(a:msg . '(yes/no): ')
  echomsg ' '
  if index(['y', 'ye', 'yes'], s:choose) > -1
    return v:true
  endif
  return v:false
endfunction

" echomsgs
function! s:U.echomsgs(msgs)
  for s:msg in s:U.to_list(a:msgs)
    echomsg s:msg
  endfor
  call input('')
endfunction

" exec
function! s:U.exec(cmd, ...)
  return execute(function('printf', [a:cmd] + a:000)())
endfunction

" escape
function! s:U.shellargs(args)
  let s:args = []
  for s:arg in s:U.to_list(a:args)
    if type(s:arg) == v:t_list
      let s:args = s:args + [join(map(s:arg, { k, v -> escape(v, ' ') }), ' ')]
      continue
    endif
    if type(s:arg) == v:t_dict
      let s:args = s:args + [s:U.opts(s:arg)]
      continue
    endif
    call add(s:args, s:arg)
  endfor
  return s:args
endfunction

" combine
function! s:U.combine(columns, values)
  let s:i = 0
  let s:dict = {}
  call gitto#test#log(a:values)
  for [s:key, s:converter] in a:columns
    let s:dict[s:key] = s:converter(a:values[s:i])
    let s:i = s:i + 1
  endfor
  return s:dict
endfunction

" opts
function! s:U.opts(opts)
  let s:args = []
  for [s:k, s:v] in items(a:opts)
    if type(s:v) == v:t_bool && s:v
      call add(s:args, s:k)
    else
      call add(s:args, s:k . '=' . s:v)
    endif
  endfor
  return join(s:args, ' ')
endfunction

" to_list
function! s:U.to_list(v)
  if type(a:v) == v:t_list
    return a:v
  endif
  return [a:v]
endfunction

" or
function! s:U.or(v1, v2)
  return strlen(a:v1) ? a:v1 : a:v2
endfunction

" chomp
function! s:U.chomp(s)
  return substitute(a:s, '\(\r\|\n\)*$', '', 'g')
endfunction

"
" status
"
let s:U.status = {}

" status.parse
function! s:U.status.parse(line)
  let s:state = strpart(a:line, 0, 2)
  let s:path = strpart(a:line, 3)
  return {
        \ 'status': s:state,
        \ 'path': fnamemodify(s:U.status.parse_path(s:state, s:path), ':p'),
        \ 'raw': a:line
        \ }
endfunction

" status.parse_path
function! s:U.status.parse_path(state, path)
  if a:state =~# 'R'
    return split(a:path, ' -> ')[1]
  endif
  return a:path
endfunction

function! gitto#util#get()
  return s:U
endfunction

