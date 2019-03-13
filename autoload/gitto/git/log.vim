let s:U = gitto#util#get()

let s:columns = [
      \ ['commit_hash', { v -> v }],
      \ ['parent_hashes', { v -> split(v, ' ') }],
      \ ['author_name', { v -> v }],
      \ ['author_email', { v -> v }],
      \ ['author_date', { v -> v }],
      \ ['subject', { v -> v }],
      \ ]

"
" `git log`
"
function! gitto#git#log#get(...)
  let opts = extend({
        \   '--max-count': 100
        \ },
        \ extend(get(a:000, 0, {}), {
        \   '--pretty': 'format:"%H%x09%P%x09%an%x09%ae%x09%ai%x09%s"'
        \ }))
  let path = get(a:000, 1, '')

  let logs = gitto#system('git log %s %s', opts, path)
  let logs = map(logs, { k, v -> s:U.combine(s:columns, split(v, "\t")) })
  let logs = filter(logs, { k, v -> !empty(v) })
  return logs
endfunction

"
" `git reset %s %s`
"
function! gitto#git#log#reset(hash, ...)
  let opts = get(a:000, 0, {})
  call s:U.echomsgs(gitto#system('git reset %s %s', opts, a:hash))
endfunction

