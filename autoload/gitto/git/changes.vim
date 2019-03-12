let s:U = gitto#util#get()

"
" `git diff %s..%s`
"
function! gitto#git#changes#get(hash1, hash2)
  let statuses = gitto#system('git diff --name-status %s..%s', a:hash1, a:hash2)
  let statuses = filter(statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  let statuses = map(statuses, { k, v -> s:U.status.parse(v) })
  return {
        \ 'from': a:hash1,
        \ 'to': a:hash2,
        \ 'statuses': statuses
        \ }
endfunction

