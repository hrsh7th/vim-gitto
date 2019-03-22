let s:U = gitto#util#get()

let s:columns = [
      \ ['HEAD', { v -> v }],
      \ ['refname', { v -> v }],
      \ ['upstream', { v -> v }],
      \ ['upstream_track', { v -> v }],
      \ ['subject', { v -> v }],
      \ ]

"
" get branches
"
function! gitto#git#branch#get(...)
  let opts = extend(get(a:000, 0, {}), {
        \ '--format': '"%(HEAD)%09%(refname)%09%(upstream)%09%(upstream:track)%09%(subject)"',
        \ '--sort': ['-authordate', 'refname:rstrip=-2']
        \ })

  let branches = map(gitto#system('git branch %s', opts), { k, v -> s:U.combine(s:columns, split(v, "\t")) })
  let branches = filter(branches, { k, v -> !empty(v) })
  let branches = map(branches, { k, v ->
        \   extend(v, {
        \     'name': s:refname2name(v.refname),
        \     'remote': s:U.or(matchstr(s:U.or(v.upstream, v.refname), '^refs/remotes/\zs[^/]\+'), 'origin'),
        \     'local': match(v.refname, '^refs/heads') >= 0 ? v:true : v:false,
        \     'current': v.HEAD ==# '*',
        \     'ahead': str2nr(s:U.or(matchstr(v.upstream_track, 'ahead\s\zs\d\+'), '0')),
        \     'behind': str2nr(s:U.or(matchstr(v.upstream_track, 'behind\s\zs\d\+'), '0')),
        \   })
        \ })
  let branches = filter(branches, { k, v -> v.name !=# 'origin/HEAD' })
  return branches
endfunction

"
" get current branch
"
function! gitto#git#branch#current()
  let branches = gitto#do('branch#get')()
  let branches = filter(branches, { k, v -> v.current })
  return get(branches, 0, {})
endfunction

"
" `git checkout %name`
"
function! gitto#git#branch#checkout(name)
  call s:U.echomsgs(gitto#system('git checkout %s', a:name))
endfunction

"
" `git branch %name`
"
function! gitto#git#branch#new(name, ...)
  call s:U.echomsgs(gitto#system('git branch %s', a:name))
endfunction

"
" `git branch -m %s %s`
"
function! gitto#git#branch#rename(name, new_name)
  call s:U.echomsgs(gitto#system('git branch -m %s %s', a:name, a:new_name))
endfunction

"
" `git branch -D %name` or `git push %remote :%name`
"
function! gitto#git#branch#delete(branch, ...)
  if a:branch['local']
    call s:U.echomsgs(gitto#system('git branch -D %s', a:branch['name']))
  else
    call s:U.echomsgs(gitto#system('git push %s :%s', a:branch['remote'], a:branch['name']))
  endif
endfunction

"
" git merge %s %s
"
function! gitto#git#branch#merge(branch, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system(
        \   'git merge %s %s',
        \   opts,
        \   a:branch['local']
        \     ? a:branch['name']
        \     : a:branch['remote'] . '/' . a:branch['name'])
        \ )
endfunction

"
" git rebase %s %s
"
function! gitto#git#branch#rebase(branch, ...)
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system(
        \   'git rebase %s %s',
        \   opts,
        \   a:branch['local']
        \     ? a:branch['name']
        \     : a:branch['remote'] . '/' . a:branch['name'])
        \ )
endfunction

"
" git push origin %s %s
"
function! gitto#git#branch#push(branch, ...)
  let opts = extend(get(a:000, 0, {}), {})
  if !a:branch['local']
    return s:U.echomsgs("can't push remote branch")
  endif
  call s:U.echomsgs(gitto#system('git push %s %s %s', opts, a:branch.remote, a:branch.name))
endfunction

"
" git pull %s %s
"
function! gitto#git#branch#pull(branch, ...)
  if !a:branch['current']
    return s:U.echomsgs("can't pull not current branch")
  endif
  if !strlen(a:branch['upstream'])
    return s:U.echomsgs('should set upstream branch')
  endif
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git pull %s %s %s', opts, a:branch.remote, a:branch.name))
endfunction

"
"git fetch %remote %remote:%local
"
function! gitto#git#branch#fetch(branch, ...)
  if !strlen(a:branch['upstream'])
    return s:U.echomsgs('should set upstream branch')
  endif
  let opts = extend(get(a:000, 0, {}), {})
  call s:U.echomsgs(gitto#system('git fetch %s %s %s:%s',
        \ opts,
        \ a:branch.remote,
        \ a:branch.name,
        \ s:refname2name(a:branch.upstream)))
endfunction

"
" git branch --set-upstream-to=%s
"
function! gitto#git#branch#set_upstream_to(branch, ...)
  let opts = extend(get(a:000, 0, {}), {
        \ '--set-upstream-to': a:branch['remote'] . '/' . a:branch['name']
        \ })
  call s:U.echomsgs(gitto#system('git branch %s', opts))
endfunction

"
" ---
"

function! s:refname2name(refname)
  return matchstr(a:refname, '\%(^refs/heads/\zs.\+\|refs/remotes/[^/]\+/\zs.\+\)')
endfunction

