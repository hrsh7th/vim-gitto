let s:utils = {}

function! vrsn#utils#get()
  return s:utils
endfunction

function! s:utils.combine(columns, values)
  let s:i = 0
  let s:dict = {}
  for [s:key, s:converter] in a:columns
    let s:dict[s:key] = s:converter(a:values[s:i])
    let s:i = s:i + 1
  endfor
  return s:dict
endfunction

function! s:utils.cmd_args(opts)
  return join(map(items(a:opts), { k, v -> strlen(v[1]) ? v[0] . '=' . v[1] : v[0] }), ' ')
endfunction

function! s:utils.or(v1, v2)
  return strlen(a:v1) ? a:v1 : a:v2
endfunction

