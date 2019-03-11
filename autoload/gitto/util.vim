let s:U = {}

"
" common
"

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

function! s:U.relative(path)
  return fnamemodify(a:path, ':.')
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
  let s:msgs = type(a:msgs) == v:t_list ? a:msgs : [' ', a:msgs]
  for s:msg in s:msgs
    echomsg s:msg
  endfor
  call input('')
endfunction

" exec
function! s:U.exec(cmd, ...)
  call gitto#test#log(a:cmd)
  return execute(function('printf', [a:cmd] + a:000)())
endfunction

" path
function! s:U.shellescape(arg)
  if type(a:arg) == v:t_list
    return map(a:arg, { k, v -> shellescape(v) })
  endif
  return shellescape(a:arg)
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
  return join(map(items(a:opts), { k, v -> strlen(v[1]) ? v[0] . '=' . v[1] : v[0] }), ' ')
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

