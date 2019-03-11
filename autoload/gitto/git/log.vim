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
  let s:opts = extend({
        \   '--max-count': 100,
        \   '--first-parent': v:true
        \ },
        \ extend(get(a:000, 0, {}), {
        \   '--pretty': 'format:"%H%x09%P%x09%an%x09%ae%x09%ai%x09%s"'
        \ }))

  let s:logs = gitto#system('git log %s', s:opts)
  let s:logs = map(s:logs, { k, v -> s:U.combine(s:columns, split(v, "\t")) })
  return s:logs
endfunction

