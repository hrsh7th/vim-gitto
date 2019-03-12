let s:U = gitto#util#get()

let g:gitto#view#config = get(g:, 'gitto#view', {})
let g:gitto#view#config.commit_msg_separator = get(g:, 'gitto#view#config.commit_msg_separator', '#####')

function! gitto#view#commit(paths)
  if len(a:paths) <= 0
    return s:U.echomsgs('nothing to commit')
  endif

  " open buffer.
  call s:U.exec('tabedit %s', join([gitto#root_dir(), '.git', 'COMMIT_EDITMSG'], '/'))
  call s:U.exec('set filetype=gitcommit')

  " initialize vars.
  let b:gitto_commit = {}
  let b:gitto_commit.paths = map(a:paths, { k, v -> s:U.relative(v) })
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

  augroup gitto
    autocmd!
    autocmd! BufWinEnter <buffer> setlocal bufhidden=wipe nobuflisted noswapfile
    autocmd! BufWritePre <buffer> execute 'silent %s/' . g:gitto#view#config.commit_msg_separator . '\_.*$//ge'
    autocmd! BufWritePost <buffer> call b:gitto_commit.commit()
  augroup END
endfunction

function! gitto#view#vimdiff(info1, info2)
endfunction

