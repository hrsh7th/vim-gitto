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
  let s:opts = get(a:000, 0, {})
  echomsg gitto#system_raw('git reset %s -- %s', s:U.opts(s:opts), a:path)
endfunction

"
" `git add`
"
function! gitto#git#status#add(path, ...)
  let s:opts = get(a:000, 0, {})
  echomsg gitto#system_raw('git add %s -- %s', s:U.opts(s:opts), a:path)
endfunction

"
" `git rm`
"
function! gitto#git#status#add(path, ...)
  let s:opts = get(a:000, 0, {})
  echomsg gitto#system_raw('git rm %s -- %s', s:U.opts(s:opts), a:path)
endfunction


"
" `git checkout`
"
function! gitto#git#status#checkout(path, ...)
  let s:opts = get(a:000, 0, {})
  echomsg gitto#system_raw('git checkout %s -- %s', s:U.opts(s:opts), a:path)
endfunction

