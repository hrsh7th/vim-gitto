"
" `git branch`
"
function! vrsn#git#branch#call(args)
  let s:branches = vrsn#system('git branch -a', vrsn#root_dir(a:args['path']))
  let s:branches = s:parse(s:branches)
  return s:branches
endfunction

function! s:parse(branches)
  let s:branches = a:branches
  return map(s:branches, { k, v -> {
        \ 'name': strpart(v, 2),
        \ 'current': match(v, '^\*') != -1,
        \ 'remote': match(strpart(v, 2), 'remote\/') != -1,
        \ 'raw': v
        \ } })
endfunction

