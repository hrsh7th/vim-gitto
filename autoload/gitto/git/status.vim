let s:U = gitto#util#get()

"
" `git status`
"
function! gitto#git#status#get()
  let statuses = gitto#system('git status --short')
  let statuses = filter(statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  let statuses = map(statuses, { k, v -> s:U.status.parse(v, 2, 3) })
  return statuses
endfunction

"
" `git reset`
"
function! gitto#git#status#reset(paths, ...)
  call s:per_status('reset', a:paths, get(a:000, 0, {}))
endfunction

"
" `git add`
"
function! gitto#git#status#add(paths, ...)
  call s:per_status('add', a:paths, get(a:000, 0, {}))
endfunction

"
" `git rm`
"
function! gitto#git#status#rm(paths, ...)
  call s:per_status('rm', a:paths, get(a:000, 0, {}))
endfunction


"
" `git checkout`
"
function! gitto#git#status#checkout(paths, ...)
  call s:per_status('checkout', a:paths, get(a:000, 0, {}))
endfunction

" ---

function! s:per_status(action, paths, opts)
  let paths = map(s:U.to_list(a:paths), { k, v -> s:U.relative(v) })
  if !len(paths)
    return s:U.echomsgs(printf('nothing to %s', a:action))
  endif
  call s:U.echomsgs(gitto#system('git %s %s -- %s', a:action, a:opts, paths))
endfunction

