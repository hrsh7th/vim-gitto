let s:U = gitto#util#get()

let s:columns = [
      \ ['HEAD', { v -> v }],
      \ ['refname', { v -> v }],
      \ ['upstream', { v -> v }],
      \ ['upstream_track', { v -> v }],
      \ ['subject', { v -> v }],
      \ ]

"
" `git branch -a`
"
function! gitto#git#branch#get(...)
  let opts = extend(get(a:000, 0, {}), {
        \ '--format': '"%(HEAD)%09%(refname)%09%(upstream)%09%(upstream:track)%09%(subject)"',
        \ '--sort': '-committerdate'
        \ })

  let branches = map(gitto#system('git branch %s', opts), { k, v -> s:U.combine(s:columns, split(v, "\t")) })
  let branches = filter(branches, { k, v -> !empty(v) })
  let branches = map(branches, { k, v ->
        \   extend(v, {
        \     'name': matchstr(v.refname, '^\%(refs/heads\|refs/remotes/[^/]\+\)/\zs.\+'),
        \     'remote': s:U.or(matchstr(s:U.or(v.upstream, v.refname), '^refs/remotes/\zs[^/]\+'), 'origin'),
        \     'current': v.HEAD ==# '*',
        \     'ahead': str2nr(s:U.or(matchstr(v.upstream_track, 'ahead\s\zs\d\+'), '0')),
        \     'behind': str2nr(s:U.or(matchstr(v.upstream_track, 'behind\s\zs\d\+'), '0')),
        \   })
        \ })
  let branches = filter(branches, { k, v1 -> empty(s:U.find(branches, { v2 -> v1.refname == v2.upstream })) })
  let branches = filter(branches, { k, v -> v.name !=# 'HEAD' })
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

