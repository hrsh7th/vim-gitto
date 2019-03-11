let s:U = gitto#util#get()

"
" `git branch -a`
"
function! gitto#git#branch#get()
  let s:branches = gitto#system('git branch -a')
  let s:branches = filter(s:branches, { k, v -> match(v, '\s\->\s') == -1 })
  let s:branches = map(s:branches, { k, v -> s:parse(v) })
  return s:branches
endfunction

"
" `git checkout %s`
"
function! gitto#git#branch#checkout(name)
  let s:branches = gitto#do('branch#get')()
  let s:exists = len(filter(s:branches, { k, v -> v.name == a:name }))
  if s:exists
    call s:U.echomsgs(gitto#system('git checkout %s', a:name))
  else
    call s:U.echomsgs(gitto#system('git checkout -b %s', a:name))
  endif
endfunction

"
" `git branch %s`
"
function! gitto#git#branch#new(name, ...)
  let s:opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git branch %s %s', s:opts, a:name))
endfunction

"
" `git branch -m %s %s`
"
function! gitto#git#branch#rename(name, new_name)
  call s:U.echomsgs(gitto#system('git branch -m %s %s', a:name, a:new_name))
endfunction

" ---

function! s:parse(branch)
  let s:mark = strpart(a:branch, 0, 2)
  let s:others = strpart(a:branch, 2)
  let s:remote = s:U.or(matchstr(s:others, '^remotes\/\zs.\+\ze\/'), 'origin')
  let s:name = matchstr(s:others, 'remotes\/\zs.\+\|^.\+$')
  return  {
        \ 'name': s:name,
        \ 'current': s:mark ==# '* ',
        \ 'remote': s:remote,
        \ 'raw': a:branch
        \ }
endfunction

