call gitto#root_dir()

let s:mode = 'commit'
let g:gitto#config.debug = 1

" status
if s:mode ==# 'status'
  for s:status in gitto#do('status#get')()
    echomsg s:status.status . ' | ' . s:status.path
  endfor
endif

" add
if s:mode ==# 'add'
  let s:paths = map(gitto#do('status#get')(), { k, v -> v.path })
  call gitto#do('status#add')(s:paths)
endif

" reset
if s:mode ==# 'reset'
  let s:paths = map(gitto#do('status#get')(), { k, v -> v.path })
  call gitto#do('status#reset')(s:paths)
endif

" commit
if s:mode ==# 'commit'
  let s:statuses = gitto#do('status#get')()
  let s:statuses = filter(s:statuses, { k, v -> v.status != '??' })
  let s:paths = map(s:statuses, { k, v -> v.path })
  call gitto#view#commit(s:paths)
endif

