let s:U = vrsn#utils#get()

let s:columns = [
      \ ['commit_hash', { v -> v }],
      \ ['parent_hashes', { v -> split(v, ' ') }],
      \ ['author_name', { v -> v }],
      \ ['author_email', { v -> v }],
      \ ['author_date', { v -> v }],
      \ ['subject', { v -> v }],
      \ ]

function! vrsn#git#log#get(opts, ...)
  let s:opts = extend({
        \   '--max-count': 100
        \ },
        \ extend(a:opts, {
        \   '--pretty': 'format:"%H%x09%P%x09%an%x09%ae%x09%ai%x09%s"',
        \   '--first-parent': ''
        \ }))

  let s:logs = vrsn#system(printf('git log %s -- %s', s:U.cmg_args(s:opts), len(a:000) ? a:000[0] : ''))
  let s:logs = map(s:logs, { k, v -> s:U.combine(s:columns, split(v, "\t")) })
  return s:logs
endfunction

