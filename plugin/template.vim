if exists('g:loaded_template')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -range Foo lua require('template').foo()
command! Bar lua require('template').bar()

let g:loaded_template = 1
