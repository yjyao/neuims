scriptencoding utf-8

let s:win_usa = 0x0409
let s:win_chs = 0x0409
let s:default_keyboards = #{
      \ win: #{0: s:win_usa, 1: s:win_chs},
      \ unix: #{0: 'xkb:us::eng', 1: 'pinyin'},
      \ }

let s:default_im_selectors = #{
        \ win: expand('<sfile>:h:h:h').'/bin/win_ims.exe',
        \ unix: 'ibus engine',
        \ }

function! neuims#GetKeyboard(state) abort
  let g:neuims_keyboards = get(g:, 'neuims_keyboards', <SID>GetDefaultKeyboards())
  try
    return g:neuims_keyboards[a:state]
  catch /Key not present in Dictionary/
    call s:EchoErr('Invalid g:neuims_keyboards = '.g:neuims_keyboards.'. Must be a two-element list.')
  endtry
endfunction

function! s:GetDefaultKeyboards() abort
  try
    return s:default_keyboards[s:GetSystem()]
  catch /Unknown operating system/
    call s:EchoErr('Cannot select default keyboards based on system. Please set g:neuims_keyboards.')
  catch /Key not present in Dictionary/
    call s:EchoErr('This is a bug. Please file an issue at https://github/yjyao/neuims.vim.')
  endtry
endfunction

function! s:GetDefaultImSelector() abort
  try
    return s:default_im_selectors[s:GetSystem()]
  catch /Unknown operating system/
    call s:EchoErr('Cannot select default IM-select binary based on system. Please set g:neuims_im_select.')
  catch /Key not present in Dictionary/
    call s:EchoErr('This is a bug. Please file an issue at https://github/yjyao/neuims.vim.')
  endtry
endfunction

function! s:GetSystem()
  if has('win32') || system('uname -r') =~ 'Microsoft'
    return 'win'
  elseif has('unix')
    return 'unix'
  endif
  throw 'Unknown operating system'
endfunction

function! neuims#Toggle() abort
  let g:neuims_activated = !g:neuims_activated
endfunction

function! neuims#Switch(state) abort
  if !g:neuims_activated
    call s:EchoMsg('neuims is disabled. Call neuims#Toggle() first.')
    return
  endif
  try
    call neuims#SelectIM(neuims#GetKeyboard(a:state))
    call s:EchoMsg((a:state ? 'Turned on' : 'Turned off').' input method.')
  catch /.*/
    call s:EchoErr(v:exception)
  endtry
endfunction

function! neuims#SelectIM(im_id)
  let g:neuims_im_select = get(g:, 'neuims_im_select', <SID>GetDefaultImSelector())
  let cmd = (g:neuims_im_select . ' ' . a:im_id)
  let msg = system(cmd)

  if v:shell_error
    throw printf('Failed to run command %s: "%s"', cmd, msg)
  endif
endfunction

function! s:EchoMsg(msg)
  call s:Echo('WarningMsg', a:msg)
endfunction

function! s:EchoErr(msg)
  call s:Echo('ErrorMsg', a:msg)
endfunction

function! s:Echo(hl, msg)
  exec 'echohl '.a:hl
  echomsg '[neuims] '.a:msg
  echohl NONE
endfunction
