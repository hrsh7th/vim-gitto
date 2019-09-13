let s:U = gitto#util#get()

"
" `git diff --name-status %s..%s`
" or
" `git diff --name-status %s`
"
function! gitto#git#changes#get(hash1, hash2)
  if a:hash2 == 'LOCAL'
    let statuses = gitto#system('git diff --name-status %s', a:hash1)
  else
    let statuses = gitto#system('git diff --name-status %s...%s', a:hash1, a:hash2)
  endif
  let statuses = filter(statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  let statuses = map(statuses, { k, v -> s:U.status.parse(v, 1, 2) })
  return {
        \ 'from': a:hash1,
        \ 'to': a:hash2,
        \ 'statuses': statuses
        \ }
endfunction

