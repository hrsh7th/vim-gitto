let s:test = {}
let s:sdir = expand('<sfile>')

function! gitto#test#set(fn, value)
  let s:test[a:fn] = a:value
endfunction

function! gitto#test#get(fn)
  return s:test[a:fn]
endfunction

function! gitto#test#has(fn)
  return has_key(s:test, a:fn)
endfunction

function! gitto#test#clear()
  let s:test = {}
endfunction

function! gitto#test#plugin_dir(path)
  return resolve(fnamemodify(s:sdir, ':p:h:h:h') . '/' . a:path)
endfunction

