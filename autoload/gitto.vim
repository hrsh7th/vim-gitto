let g:gitto#config = get(g:, 'gitto#config', {})
let g:gitto#config.get_buffer_path = get(g:gitto#config, 'get_buffer_path', { -> expand('%:p')})

function! gitto#do(name)
  let s:fn = function(printf('gitto#git#%s', a:name))
  return { -> s:run_in_dir(
        \ gitto#root_dir(g:gitto#config.get_buffer_path()),
        \ function(s:fn, [] + a:000)) }
endfunction

function! gitto#root_dir(path)
  let s:path = a:path
  let s:path = finddir('.git', fnamemodify(s:path, ':p:h') . ';')
  let s:path = strlen(s:path) ? fnamemodify(s:path, ':p:h:h') : ''
  return s:path
endfunction

function! gitto#system(cmd, ...)
  if gitto#test#has('gitto#system')
    return gitto#test#get('gitto#system')
  endif

  let s:output = split(system(function('printf', [a:cmd] + a:000)()), "\n")
  let s:output = map(s:output, 's:chomp(v:val)')
  let s:output = filter(s:output, 'strlen(v:val)')
  return s:output
endfunction

function! gitto#system_raw(cmd, ...)
  if gitto#test#has('gitto#system_raw')
    return gitto#test#get('gitto#system_raw')
  endif

  return system(function('printf', [a:cmd] + a:000)())
endfunction

function! s:run_in_dir(cwd, Fn)
  let s:cwd = getcwd()
  try
    call s:lcd(a:cwd)
    let s:return = a:Fn()
  finally
    call s:lcd(s:cwd)
  endtry
  return s:return
endfunction

function! s:chomp(s)
  return substitute(a:s, '\r\|\n', '', 'g')
endfunction

function! s:lcd(dir)
  execute printf('lcd %s', a:dir)
endfunction

function! s:dir(path)
  if !isdirectory(a:path)
    return fnamemodify(a:path, 'p:h')
  endif
  return a:path
endfunction
