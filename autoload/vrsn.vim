function! s:get_buffer_path()
  return expand('%:p')
endfunction

let g:vrsn#config = get(g:, 'vrsn#config', {})
let g:vrsn#config.get_buffer_path = get(g:vrsn#config, 'get_buffer_path', function('s:get_buffer_path'))

function! vrsn#call(namespace, name, ...)
  let s:fn = len(a:000)
        \ ? function(printf('vrsn#git#%s#%s', a:namespace, a:name), a:000)
        \ : function(printf('vrsn#git#%s#%s', a:namespace, a:name))
  return s:run_in_dir(vrsn#root_dir(g:vrsn#config.get_buffer_path()), s:fn)
endfunction

function! vrsn#root_dir(path)
  let s:path = a:path
  let s:path = finddir('.git', fnamemodify(s:path, ':p:h') . ';')
  let s:path = strlen(s:path) ? fnamemodify(s:path, ':p:h:h') : ''
  return s:path
endfunction

function! vrsn#system(cmd)
  if vrsn#test#has('vrsn#system')
    return vrsn#test#get('vrsn#system')
  endif

  let s:output = split(system(printf('%s', a:cmd)), "\n")
  let s:output = map(s:output, 's:chomp(v:val)')
  let s:output = filter(s:output, 'strlen(v:val)')
  return s:output
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
