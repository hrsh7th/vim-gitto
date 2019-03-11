let s:U = gitto#util#get()

let g:gitto#view#config = get(g:, 'gitto#view', {})
let g:gitto#view#config.commit_msg_separator = get(g:, 'gitto#view#config.commit_msg_separator', '#####')

function! gitto#view#commit(paths)
  if len(a:paths) <= 0
    return s:U.echomsgs('nothing to commit')
  endif

  let s:root_dir = gitto#root_dir()
  let s:msg_file = join([s:root_dir, '.git', 'COMMIT_EDITMSG'], '/')
  let s:paths = map(a:paths, { k, v -> s:U.relative(v, s:root_dir) })

  call s:U.exec('tabedit %s', s:msg_file)
  call s:U.exec('set filetype=gitcommit')

  silent % delete _

  put=g:gitto#view#config.commit_msg_separator
  put=s:U.run_in_dir(s:root_dir, { -> gitto#system('git commit --dry-run --quiet -v -- %s', s:paths) })
  noautocmd write!

  call cursor(1, 1)

  augroup gitto
    autocmd!
    autocmd! BufWinEnter <buffer> setlocal bufhidden=wipe nobuflisted noswapfile
    autocmd! BufWritePre <buffer> execute 'silent %s/' . escape(g:gitto#view#config.commit_msg_separator, '[]') . '\_.*//ge'
    autocmd! BufWritePost <buffer> call s:commit()

    function! s:commit()
      if s:U.yes_or_no('commit?')
        call s:U.echomsgs(
              \   s:U.run_in_dir(s:root_dir, { -> gitto#system('git commit -F %s -- %s', s:msg_file, s:paths) })
              \ )
      endif
      bdelete!
    endfunction
  augroup END
endfunction

function! gitto#view#vimdiff(info1, info2)
endfunction

