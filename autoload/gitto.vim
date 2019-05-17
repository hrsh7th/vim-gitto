let g:gitto#config = get(g:, 'gitto#config', {})
let g:gitto#config.get_buffer_path = get(g:gitto#config, 'get_buffer_path', { -> expand('%:p') })

let s:U = gitto#util#get()

function! gitto#run(feature, ...)
  let dir = g:gitto#config.get_buffer_path()
  return call(function('gitto#run_in_dir'), [dir, a:feature] + a:000)
endfunction

function! gitto#run_in_dir(dir, feature, ...)
  let fname = printf('gitto#git#%s', a:feature)
  call s:U.autoload_by_funcname(fname)
  return s:U.run_in_dir(gitto#root_dir(a:dir), function(fname, a:000))
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

  let command = call('printf', [a:cmd] + s:U.shellargs(a:000))
  let output = split(system(command), "[\n\r]")
  let output = map(output, { k, v -> s:U.chomp(v) })
  return output
endfunction

function! gitto#system_echo(cmd, ...)
  let command = call('printf', [a:cmd] + s:U.shellargs(a:000))
  echo ' '
  echo ' '
  echo '$ ' . command
  call s:U.echomsgs(function('gitto#system', [a:cmd] + a:000)(), v:false)
  echo ' '
endfunction

