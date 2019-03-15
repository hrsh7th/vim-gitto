let s:U = gitto#util#get()

"
" `git branch -a`
"
function! gitto#git#branch#get(...)
  let opts = extend(get(a:000, 0, {}), {})
  let branches = gitto#system('git branch %s', opts)
  let branches = filter(branches, { k, v -> match(v, '\s\->\s') == -1 })
  let branches = map(branches, { k, v -> s:parse(v) })
  let branches = s:U.uniq(branches, { v -> v.remote . '/' . v.name })
  return branches
endfunction

"
" `git branch -a`
"
function! gitto#git#branch#current()
  let branches = gitto#do('branch#get')()
  let branches = filter(branches, { k, v -> v.current })
  return get(branches, 0, {})
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

"
" git merge %s %s
"
function! gitto#git#branch#merge(name, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git merge %s %s', opts, a:name))
endfunction

"
" git rebase %s %s
"
function! gitto#git#branch#rebase(name, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git rebase %s %s', opts, a:name))
endfunction

"
" git push origin %s %s
"
function! gitto#git#branch#push(branch, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git push origin %s %s', opts, a:branch.name))
endfunction

"
" git pull %s %s
"
function! gitto#git#branch#pull(branch, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git pull %s %s %s', opts, a:branch.remote, a:branch.name))
endfunction

" ---

function! s:parse(branch)
  let mark = strpart(a:branch, 0, 2)
  let others = strpart(a:branch, 2)
  let remote = s:U.or(matchstr(others, '^remotes\/\zs.\+\ze\/'), 'origin')
  let name = matchstr(others, 'remotes\/[^\/]\+\/\zs.\+\|^.\+$')
  return  {
        \ 'name': name,
        \ 'current': mark ==# '* ',
        \ 'remote': remote,
        \ 'raw': a:branch
        \ }
endfunction

