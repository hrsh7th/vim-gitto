# vim-gitto
git client in vim.

# usage

## API

### gitto#do(feature)(...args) -> lambda
You can call feature like this.

```
call gitto#do('status#get')()
call gitto#do('status#reset')('/path/to/file')
```

### gitto#run(feature, [...args]) -> results
You can call feature like this.

```
call gitto#run('status#get')
call gitto#run('status#reset', '/path/to/file')
```

NOTE: You might not need this. It's used by neovim's remote plugin.

## Feature

### status#get() -> { status, path, raw }[]
`git status`

### status#reset(paths) -> void
`git reset -- path`

### status#checkout(paths) -> void
`git checkout -- path`


### status#add(paths) -> void
`git add -- path`

### status#rm(paths) -> void
`git rm -- path`

... and more.

You can find other feature in `autoload/gitto/git/*.vim`.

# FAQ

Q.
> I want to use this on `special plugin's buffer`. But it's not work.

A.
> You can override implementaion for detect git repo like this.
```
let g:gitto#config = {}
function! g:gitto#config.get_buffer_path()
  if exists('b:defx')
    return b:defx.paths[0]
  endif
  return expand('%:p')
endfunction
```

