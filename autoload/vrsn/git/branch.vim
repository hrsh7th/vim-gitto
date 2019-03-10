let s:U = vrsn#utils#get()

"
" `git branch`
"
function! vrsn#git#branch#get()
  let s:branches = vrsn#system('git branch -a')
  let s:branches = filter(s:branches, { k, v -> match(v, '\s\->\s') == -1 })
  let s:branches = map(s:branches, { k, v -> s:parse(v) })
  return s:branches
endfunction

" ---

function! s:parse(branch)
  let s:mark = strpart(a:branch, 0, 2)
  let s:others = strpart(a:branch, 2)
  let s:remote = s:U.or(matchstr(s:others, '^remotes\/\zs.\+'), 'origin')
  let s:name = matchstr(s:others, 'remotes\/\zs.\+\|^.\+$')
  return  {
        \ 'name': s:name,
        \ 'current': s:mark ==# '* ',
        \ 'remote': s:remote,
        \ 'raw': a:branch
        \ }
endfunction


call vrsn#git#branch#get()
