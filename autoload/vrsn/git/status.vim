"
" `git status`
"
function! vrsn#git#status#call(args)
  let s:statuses = vrsn#system('git status --short', vrsn#root_dir(a:args['path']))
  let s:statuses = s:parse(s:statuses)
  return s:statuses
endfunction

function! s:parse(statuses)
  let s:statuses = a:statuses
  let s:statuses = filter(s:statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  return map(s:statuses, { k, v -> {
        \ 'status': strpart(v, 0, 2),
        \ 'path': strpart(v, 3),
        \ 'raw': v
        \ } })
endfunction

