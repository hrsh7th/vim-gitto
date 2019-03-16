let s:U = gitto#util#get()

function! gitto#git#repo#head()
  if !filereadable(getcwd() . '/.git/HEAD')
    throw 'not in git repo'
  endif
  let l = readfile(getcwd() . '/.git/HEAD')[0]
  return matchstr(l, 'ref: refs/heads/\zs.\+')
endfunction

function! gitto#git#repo#push(...)
  let current = gitto#do('branch#current')()
  if empty(current)
    return s:U.echomsgs("current branch can't detect.")
  endif
  if !current.upstream
    return s:U.echomsgs('should set upstream branch.')
  endif
  call call(gitto#do('branch#push'), [current] + a:000)
endfunction

function! gitto#git#repo#pull(...)
  let current = gitto#do('branch#current')()
  if empty(current)
    return s:U.echomsgs("current branch can't detect.")
  endif
  if !current.upstream
    return s:U.echomsgs('should set upstream branch.')
  endif
  call call(gitto#do('branch#pull'), [current] + a:000)
endfunction

