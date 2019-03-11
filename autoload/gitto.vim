let g:gitto#config = get(g:, 'gitto#config', {})
let g:gitto#config.get_buffer_path = get(g:, 'gitto#config.get_buffer_path', { -> expand('%:p') })
let g:gitto#config.debug = get(g:, 'gitto#config.debug', 0)

let s:U = gitto#util#get()

function! gitto#do(name)
  let s:fname = printf('gitto#git#%s', a:name)

  call s:U.autoload_by_funcname(s:fname)

  return { ->
        \   s:U.run_in_dir(
        \     gitto#root_dir(g:gitto#config.get_buffer_path()),
        \     funcref(s:fname, a:000)
        \   )
        \ }
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

  let s:cmd = call('printf', [a:cmd] + s:U.shellargs([] + a:000))
  if g:gitto#config.debug
    echomsg s:cmd
  endif
  let s:output = split(system(s:cmd), "\n")
  let s:output = map(s:output, { k, v -> s:U.chomp(v) })
  return s:output
endfunction

