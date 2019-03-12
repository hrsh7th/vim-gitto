let s:U = gitto#util#get()

"
" `git branch -a`
"
function! gitto#git#branch#get()
  let branches = gitto#system('git branch -a')
  let branches = filter(branches, { k, v -> match(v, '\s\->\s') == -1 })
  let branches = map(branches, { k, v -> s:parse(v) })
  return branches
endfunction

"
" `git checkout %s`
"
function! gitto#git#branch#checkout(name)
  let branches = gitto#do('branch#get')()
  let exists = len(filter(branches, { k, v -> v.name == a:name }))
  if exists
    call s:U.echomsgs(gitto#system('git checkout %s', a:name))
  else
    call s:U.echomsgs(gitto#system('git checkout -b %s', a:name))
  endif
endfunction

"
" `git branch %s`
"
function! gitto#git#branch#new(name, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git branch %s %s', opts, a:name))
endfunction

"
" `git branch -m %s %s`
"
function! gitto#git#branch#rename(name, new_name)
  call s:U.echomsgs(gitto#system('git branch -m %s %s', a:name, a:new_name))
endfunction

" ---

function! s:parse(branch)
  let mark = strpart(a:branch, 0, 2)
  let others = strpart(a:branch, 2)
  let remote = s:U.or(matchstr(others, '^remotes\/\zs.\+\ze\/'), 'origin')
  let name = matchstr(others, 'remotes\/\zs.\+\|^.\+$')
  return  {
        \ 'name': name,
        \ 'current': mark ==# '* ',
        \ 'remote': remote,
        \ 'raw': a:branch
        \ }
endfunction

