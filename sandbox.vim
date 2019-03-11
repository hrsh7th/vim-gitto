call gitto#root_dir()

let s:mode = input('choose(status, branch, branch/new, branch/rename, branch/checkout, log, add, reset, commit): ')
let g:gitto#config.debug = 1

" status
if s:mode ==# 'status'
  for s:status in gitto#do('status#get')()
    echomsg s:status.status . ' | ' . s:status.path
  endfor
endif

" branch
if s:mode ==# 'branch'
  for s:branch in gitto#do('branch#get')()
    echomsg s:branch.remote . ' | ' . s:branch.name
  endfor
endif

" branch/new
if s:mode ==# 'branch/new'
  call gitto#do('branch#new')(input('newname: '))
endif

" branch/rename
if s:mode ==# 'branch/rename'
  call gitto#do('branch#rename')(input('target: '), input('newname: '))
endif

" branch/checkout
if s:mode ==# 'branch/checkout'
  call gitto#do('branch#checkout')(input('target: '))
endif

" log
if s:mode ==# 'log'
  for s:log in gitto#do('log#get')()
    echomsg s:log.author_name . ' | ' . s:log.commit_hash . ' | ' . s:log.subject
  endfor
endif

" add
if s:mode ==# 'add'
  call gitto#do('status#add')(map(gitto#do('status#get')(), { k, v -> v.path }))
endif

" reset
if s:mode ==# 'reset'
  call gitto#do('status#reset')(map(gitto#do('status#get')(), { k, v -> v.path }))
endif

" commit
if s:mode ==# 'commit'
  let s:statuses = gitto#do('status#get')()
  let s:statuses = filter(s:statuses, { k, v -> v.status != '??' })
  let s:paths = map(s:statuses, { k, v -> v.path })
  call gitto#view#commit(s:paths)
endif

