let s:U = gitto#util#get()

function! gitto#git#show#get(hash, path)
  return gitto#system('git cat-file -p %s:./%s', a:hash, s:U.relative(a:path))
endfunction

