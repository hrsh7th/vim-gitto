let s:test = {}

function! vrsn#test#set(fn, value)
  let s:test[a:fn] = a:value
endfunction

function! vrsn#test#get(fn)
  return s:test[a:fn]
endfunction

function! vrsn#test#has(fn)
  return has_key(s:test, a:fn)
endfunction

function! vrsn#test#clear()
  let s:test = {}
endfunction

