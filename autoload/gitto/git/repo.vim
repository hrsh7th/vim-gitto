let s:U = gitto#util#get()

function! gitto#git#repo#head()
  if !filereadable(getcwd() . '/.git/HEAD')
    throw 'not in git repo'
  endif
  let l = readfile(getcwd() . '/.git/HEAD')[0]
  return matchstr(l, 'ref: refs/heads/\zs.\+')
endfunction

function! gitto#git#repo#fetch(...)
  let opts = extend(get(a:000, 0, {}), {})
  call gitto#system_echo('git fetch %s', opts)
endfunction

function! gitto#git#repo#push(...)
  let current = gitto#run('branch#current')
  if empty(current)
    return s:U.echomsgs("current branch can't detect.")
  endif
  call call(function('gitto#run'), ['branch#push', current] + a:000)
endfunction

function! gitto#git#repo#pull(...)
  let current = gitto#run('branch#current')
  if empty(current)
    return s:U.echomsgs("current branch can't detect.")
  endif
  if !strlen(current.upstream)
    return s:U.echomsgs('should set upstream branch.')
  endif
  call call(function('gitto#run'), ['branch#pull', current] + a:000)
endfunction

