function! gitto#git#show#get(hash, path)
  return gitto#system('git show %s:%s', a:hash, a:path)
endfunction

