let s:plugin_dir = expand('<sfile>:p:h:h')

let s:U = {}

"
" common
"

" autoload_by_funcname
function! s:U.autoload_by_funcname(fname)
  if !exists('*' . a:fname)
    let file = a:fname
    let file = substitute(file, '#', '/', 'g')
    let file = substitute(file, '/[^/]*$', '.vim', 'g')
    let file = printf('%s/%s', s:plugin_dir, file)
    if filereadable(file)
      execute printf('source %s', file)
    endif
  endif
endfunction

" run_in_dir
function! s:U.run_in_dir(dir, fn)
  let cwd = getcwd()
  try
    execute printf('lcd %s', a:dir)
    let output = a:fn()
  finally
    execute printf('lcd %s', cwd)
  endtry
  return output
endfunction

" relative
function! s:U.relative(path, ...)
  return s:U.run_in_dir(get(a:000, 0, getcwd()), { -> fnamemodify(a:path, ':.') })
endfunction

" absolute
function! s:U.absolute(path, ...)
  return resolve(get(a:000, 0, getcwd()) . '/' . a:path)
endfunction

" yes_or_no
function! s:U.yes_or_no(msg)
  let choose = input(a:msg . '(yes/no): ')
  echomsg ' '
  if index(['y', 'ye', 'yes'], choose) > -1
    return v:true
  endif
  return v:false
endfunction

" find
function! s:U.find(list, finder)
  for v in a:list
    let item = a:finder(v)
    if !empty(item)
      return item
    endif
  endfor
  return {}
endfunction

" uniq
function! s:U.uniq(list, identity)
  let keys = {}
  let list = []
  for v in a:list
    let id = a:identity(v)
    if has_key(keys, id)
      continue
    endif
    let keys[id] = v:true
    call add(list, v)
  endfor
  return list
endfunction

" echomsgs
function! s:U.echomsgs(msgs, ...)
  let output = 0
  for msg in s:U.to_list(a:msgs)
    let output = output || match(msg, '[^[:blank:]]') >= 0
    echomsg msg
  endfor
  if output && get(a:000, 0, 1)
    call getchar()
  endif
endfunction

" exec
function! s:U.exec(cmd, ...)
  return execute(call('printf', [a:cmd] + a:000))
endfunction

" escape
function! s:U.shellargs(args)
  let args = []
  for arg in s:U.to_list(a:args)
    if type(arg) == v:t_list
      let args = args + [join(map(arg, { k, v -> fnameescape(v) }), ' ')]
      continue
    endif
    if type(arg) == v:t_dict
      let args = args + [s:U.opts(arg)]
      continue
    endif
    call add(args, arg)
  endfor
  return args
endfunction

" combine
function! s:U.combine(columns, values)
  try
    let i = 0
    let dict = {}
    for [key, Converter] in a:columns
      let dict[key] = Converter(a:values[i])
      let i = i + 1
    endfor
    return dict
  catch
  endtry
  return {}
endfunction

" opts
function! s:U.opts(opts)
  let args = []
  for [k, v] in items(a:opts)
    if type(v) == v:t_bool
      if v
        call add(args, k)
      endif
    else
      call add(args, k . '=' . v)
    endif
  endfor
  return join(args, ' ')
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
  return substitute(a:s, '\(\r\n\|\r\|\n\)*$', '', 'g')
endfunction

"
" status
"
let s:U.status = {}

" status.parse
function! s:U.status.parse(line, status_offset, path_offset)
  let status = strpart(a:line, 0, a:status_offset)
  let path = strpart(a:line, a:path_offset)
  return {
        \ 'status': status,
        \ 'path': s:U.absolute(s:U.status.parse_path(status, path)),
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

