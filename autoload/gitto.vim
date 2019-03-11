let g:gitto#config = get(g:, 'gitto#config', {})
let g:gitto#config.get_buffer_path = get(g:gitto#config, 'get_buffer_path', { -> expand('%:p')})

let s:U = gitto#util#get()

function! gitto#do(name)
  let s:fn = function(printf('gitto#git#%s', a:name))
  function! s:do(...)
    return s:U.run_in_dir(
        \ gitto#root_dir(g:gitto#config.get_buffer_path()),
        \ function(s:fn, [] + a:000))
  endfunction
  return function('s:do')
endfunction

function! gitto#root_dir(...)
  let s:path = get(a:000, 0, g:gitto#config.get_buffer_path())
  let s:path = finddir('.git', fnamemodify(s:path, ':p:h') . ';')
  let s:path = strlen(s:path) ? fnamemodify(s:path, ':p:h:h') : ''
  return s:path
endfunction

function! gitto#system(cmd, ...)
  if gitto#test#has('gitto#system')
    return gitto#test#get('gitto#system')
  endif

  let s:output = split(system(function('printf', [a:cmd] + a:000)()), "\n")
  let s:output = map(s:output, { k, v -> s:U.chomp(v) })
  return s:output
endfunction

