let s:U = {}

"
" common
"
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

function! s:U.opts(opts)
  return join(map(items(a:opts), { k, v -> strlen(v[1]) ? v[0] . '=' . v[1] : v[0] }), ' ')
endfunction

function! s:U.or(v1, v2)
  return strlen(a:v1) ? a:v1 : a:v2
endfunction

function! s:U.chomp(s)
  return substitute(a:s, '\(\r\|\n\)*$', '', 'g')
endfunction

"
" status
"
let s:U.status = {}

function! s:U.status.parse(line)
  let s:state = strpart(a:line, 0, 2)
  let s:path = strpart(a:line, 3)
  return {
        \ 'status': s:state,
        \ 'path': fnamemodify(s:U.status.parse_path(s:state, s:path), ':p'),
        \ 'raw': a:line
        \ }
endfunction

function! s:U.status.parse_path(state, path)
  if a:state =~# 'R'
    return split(a:path, ' -> ')[1]
  endif
  return a:path
endfunction

function! gitto#util#get()
  return s:U
endfunction

