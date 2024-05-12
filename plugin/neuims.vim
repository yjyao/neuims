scriptencoding utf-8

if exists('g:loaded_neuims')
  finish
endif
let g:loaded_neuims = 1

let g:neuims_activated = get(g:, 'neuims_activated', 0)

let s:save_cpo = &cpoptions
set cpoptions&vim

augroup neuims
  autocmd!
  autocmd InsertEnter * call neuims#Switch(1)
  autocmd InsertLeave * call neuims#Switch(0)
  autocmd VimLeave * call neuims#Switch(0)
augroup END

command! IMSToggle call neuims#Toggle()

let &cpoptions = s:save_cpo
unlet s:save_cpo
