let s:U = gitto#util#get()

let g:gitto#view#config = get(g:, 'gitto#view#config', {})
let g:gitto#view#config.commit_msg_separator = get(g:gitto#view#config, 'commit_msg_separator', '#####')

function! gitto#view#commit(paths)
  if len(a:paths) <= 0
    return s:U.echomsgs('nothing to commit')
  endif

  " open buffer.
  call s:U.exec('tabedit %s', join([gitto#root_dir(), '.git', 'COMMIT_EDITMSG'], '/'))
  call s:U.exec('set filetype=gitcommit')

  " initialize vars.
  let b:gitto_commit = {}
  let b:gitto_commit.paths = map(a:paths, { k, v -> s:U.relative(v, gitto#root_dir()) })
  function! b:gitto_commit.commit()
    if s:U.yes_or_no('commit?')
      call s:U.echomsgs(
            \   s:U.run_in_dir(
            \     gitto#root_dir(),
            \     { -> gitto#system('git commit -F %s -- %s', expand('%:p'), b:gitto_commit.paths) }
            \   )
            \ )
    endif
    bdelete!
  endfunction

  " initialize buffer.
  silent % delete _
  put=g:gitto#view#config.commit_msg_separator
  put=s:U.run_in_dir(
        \   gitto#root_dir(),
        \   { -> gitto#system('git commit --dry-run --quiet -v -- %s', b:gitto_commit.paths) }
        \ )
  noautocmd write!
  call cursor(1, 1)

  augroup gitto_commit
    autocmd!
    autocmd! BufWinEnter <buffer> setlocal bufhidden=wipe nobuflisted noswapfile
    autocmd! BufWritePre <buffer> execute 'silent %s/' . g:gitto#view#config.commit_msg_separator . '\_.*$//ge'
    autocmd! BufWritePost <buffer> call b:gitto_commit.commit()
  augroup END
endfunction

function! gitto#view#diff_file_with_hash(path, info)
  if !filereadable(a:path)
    return s:U.echomsgs(printf('`%s` is not found.', a:path))
  endif

  let content = gitto#do('show#get')(a:info.hash, a:info.path)

  call s:U.exec('tabedit %s', a:path)
  diffthis

  vnew
  put!=content
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  diffthis

  silent! wincmd p
endfunction

function! gitto#view#diff_hash_with_hash(info1, info2)
  let content1 = gitto#do('show#get')(a:info1.hash, a:info1.path)
  let content2 = gitto#do('show#get')(a:info2.hash, a:info2.path)

  " content1
  tabnew
  put!=content1
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  diffthis

  " content2
  vnew
  put!=content2
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  diffthis

  silent! wincmd p
endfunction

