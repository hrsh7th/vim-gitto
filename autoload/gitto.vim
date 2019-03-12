let g:gitto#config = get(g:, 'gitto#config', {})
let g:gitto#config.get_buffer_path = get(g:gitto#config, 'get_buffer_path', { -> expand('%:p') })

let s:U = gitto#util#get()

function! gitto#run(name, ...)
  return call(gitto#do(a:name), a:000)
endfunction

function! gitto#do(name)
  let fname = printf('gitto#git#%s', a:name)

  call s:U.autoload_by_funcname(fname)

  return { ->
        \   s:U.run_in_dir(
        \     gitto#root_dir(g:gitto#config.get_buffer_path()),
        \     funcref(fname, a:000)
        \   )
        \ }
endfunction

function! gitto#root_dir(...)
  let path = get(a:000, 0, g:gitto#config.get_buffer_path())
  let path = finddir('.git', fnamemodify(path, ':p:h') . ';')
  let path = strlen(path) ? fnamemodify(path, ':p:h:h') : ''
  return path
endfunction

function! gitto#system(cmd, ...)
  if gitto#test#has('gitto#system')
    return gitto#test#get('gitto#system')
  endif

  let output = split(system(call('printf', [a:cmd] + s:U.shellargs(a:000))), "\n")
  let output = map(output, { k, v -> s:U.chomp(v) })
  return output
endfunction

