
function! vrsn#call(fn, args)
  if !has_key(a:args, 'path')
    echomsg '`vrsn#call` required `args.path`.'
    return
  endif
  return function(printf('vrsn#git#%s#call', a:fn))(a:args)
endfunction

function! vrsn#root_dir(path)
  let s:path = a:path
  let s:path = finddir('.git', fnamemodify(s:path, ':p:h') . ';')

  if s:path == ''
    throw printf('`%s` is not valid git path.', a:path)
  endif

  let s:path = fnamemodify(s:path, ':p:h:h')
  return s:path
endfunction

function! vrsn#system(cmd, target_cwd)
  let s:current_cwd = getcwd()
  try
    execute printf('lcd %s', a:target_cwd)
    let s:output = system(printf('%s', a:cmd))
  finally
    execute printf('lcd %s', s:current_cwd)
  endtry

  let s:output = split(s:output, "\n")
  let s:output = map(s:output, { k, v -> s:trim(v) })
  let s:output = filter(s:output, { k, v -> strlen(v) > 0 })
  return s:output
endfunction

function! s:trim(s)
  return substitute(a:s, "\r", '', 'g')
endfunction

