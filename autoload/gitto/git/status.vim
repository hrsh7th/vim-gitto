let s:U = gitto#util#get()

"
" `git status`
"
function! gitto#git#status#get()
  let s:statuses = gitto#system('git status --short')
  let s:statuses = filter(s:statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  let s:statuses = map(s:statuses, { k, v -> s:U.status.parse(v) })
  return s:statuses
endfunction

"
" `git reset`
"
function! gitto#git#status#reset(path, ...)
  call s:per_status('reset', a:path, get(a:000, 0, {}))
endfunction

"
" `git add`
"
function! gitto#git#status#add(path, ...)
  call s:per_status('add', a:path, get(a:000, 0, {}))
endfunction

"
" `git rm`
"
function! gitto#git#status#rm(path, ...)
  call s:per_status('rm', a:path, get(a:000, 0, {}))
endfunction


"
" `git checkout`
"
function! gitto#git#status#checkout(path, ...)
  call s:per_status('checkout', a:path, get(a:000, 0, {}))
endfunction

" ---

function! s:per_status(action, path, opts)
  call s:U.echomsgs(gitto#system('git %s %s -- %s', a:action, s:U.opts(a:opts), s:U.relative(a:path)))
endfunction

