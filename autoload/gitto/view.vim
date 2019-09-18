let s:U = gitto#util#get()

let g:gitto#view#config = get(g:, 'gitto#view#config', {})
let g:gitto#view#config.commit_msg_separator = get(g:gitto#view#config, 'commit_msg_separator', '#####')

"
" @param {string[]} paths
"
function! gitto#view#commit(paths, amend)
  if len(a:paths) <= 0
    return s:U.echomsgs('nothing to commit')
  endif

  " If amend enabled, enter commit step immediately.
  if a:amend
    let log = get(s:U.run_in_dir(gitto#root_dir(), { -> gitto#run('log#get', { '--max-count': 1 }) }), 0, {})
    let msg = input('message: ', get(log, 'subject', ''))
    if s:U.yes_or_no('commit?')
      call s:U.echomsgs(
            \   s:U.run_in_dir(
            \     gitto#root_dir(),
            \     { -> gitto#system('git commit %s -m "%s" -- %s',
            \       a:amend ? '--amend' : '',
            \       substitute(msg, '"', '\\"', 'g'),
            \       a:paths)
            \     }
            \   )
            \ )
    endif
    return
  endif

  " open buffer.
  call s:U.exec('tabedit %s', join([gitto#root_dir(), '.git', 'COMMIT_EDITMSG'], '/'))
  call s:U.exec('set filetype=gitcommit')

  " initialize vars.
  let b:gitto_commit = {}
  let b:gitto_commit.amend = a:amend
  let b:gitto_commit.paths = map(a:paths, { k, v -> s:U.relative(v, gitto#root_dir()) })
  function! b:gitto_commit.commit()
    if s:U.yes_or_no('commit?')
      call s:U.echomsgs(
            \   s:U.run_in_dir(
            \     gitto#root_dir(),
            \     { -> gitto#system('git commit %s -F %s -- %s',
            \       b:gitto_commit.amend ? '--amend' : '',
            \       expand('%:p'),
            \       b:gitto_commit.paths)
            \     }
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
        \   { -> gitto#system('git commit --dry-run -v -- %s',
        \     b:gitto_commit.paths)
        \   }
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

"
" @param {string} dir
" @param {string[]} paths
"
function! gitto#view#commit_in_dir(dir, paths, amend)
  return s:U.run_in_dir(gitto#root_dir(a:dir), function('gitto#view#commit', [a:paths, a:amend]))
endfunction

"
" @param {string} path
" @param {{ hash: string; path: string }} info
"
function! gitto#view#diff_file_with_hash(path, info)
  let content = call(function('gitto#run'), ['show#get', a:info.hash, a:info.path])

  call s:put_content('tabnew', a:info, content)
  silent! diffthis
  normal! zM

  call s:U.exec('topleft vsplit %s', a:path)
  silent! diffthis
  normal! zM

  normal! gg
endfunction

"
" @param {string} dir
" @param {string} path
" @param {{ hash: string; path: string }} info
"
function! gitto#view#diff_file_with_hash_in_dir(dir, path, info)
  return s:U.run_in_dir(gitto#root_dir(a:dir), function('gitto#view#diff_file_with_hash', [a:path, a:info]))
endfunction

"
" @param {{ hash: string; path: string }} info1
" @param {{ hash: string; path: string }} info2
"
function! gitto#view#diff_hash_with_hash(info1, info2)
  let content1 = call(function('gitto#run'), ['show#get', a:info1.hash, a:info1.path])
  let content2 = call(function('gitto#run'), ['show#get', a:info2.hash, a:info2.path])

  call s:put_content('tabnew', a:info2, content2)
  silent! diffthis
  normal! zM

  call s:put_content('topleft vnew', a:info1, content1)
  silent! diffthis
  normal! zM

  normal! gg
endfunction

"
" @param {string} dir
" @param {{ hash: string; path: string }} info1
" @param {{ hash: string; path: string }} info2
"
function! gitto#view#diff_hash_with_hash_in_dir(dir, info1, info2)
  return s:U.run_in_dir(gitto#root_dir(a:dir), function('gitto#view#diff_hash_with_hash', [a:info1, a:info2]))
endfunction

"
" @param {string} open
" @param {{ hash: string; path: string }} info
" @param {string} content
"
function! s:put_content(open, info, content)
  call s:U.exec('%s', a:open)
  try
    call s:U.exec('file! %s', fnameescape(substitute(a:info.path, '\(\.[^\.]\+\)$', '~' . a:info.hash . '\1', 'g')))
  catch
    call s:U.exec('edit %s', fnameescape(substitute(a:info.path, '\(\.[^\.]\+\)$', '~' . a:info.hash . '\1', 'g')))
    return
  endtry
  silent! put!=a:content | $delete
  setlocal bufhidden=hide buftype=nofile nobuflisted noswapfile nomodifiable nomodified
  filetype detect
endfunction

