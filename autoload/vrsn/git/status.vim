"
" `git status`
"
function! vrsn#git#status#get()
  let s:statuses = vrsn#system('git status --short')
  let s:statuses = filter(s:statuses, { k, v -> match(v, '^[?MADRCU ]\+') != -1 })
  let s:statuses = map(s:statuses, { k, v -> s:parse(v) })
  return s:statuses
endfunction

" ---

function! s:parse(status)
  let s:state = strpart(a:status, 0, 2)
  let s:path = strpart(a:status, 3)
  return {
        \ 'status': s:state,
        \ 'path': fnamemodify(s:parse_path(s:state, s:path), ':p'),
        \ 'raw': a:status
        \ }
endfunction

function! s:parse_path(status, path)
  if a:status =~# 'R'
    return split(a:path, ' -> ')[1]
  endif
  return a:path
endfunction

