" vamoose.vim
" Author: Ted Tibbetts <intuited à j'y aimé à y elle point com>
" License: Licensed under the same terms as Vim itself.
" Vim Access to Macros in OpenOffice Session Environments
" This plugin exists for the purpose of
" making editing OOBasic macros ever so slightly less painful.
if exists('g:loaded_vamoose') || &cp
  finish
endif
let g:loaded_vamoose = 1

" The autocommand stuff normally drives everything.
augroup vamoose_files
  autocmd!
  autocmd BufReadCmd  vamoose://**  exe vamoose#pull()
  autocmd BufWriteCmd vamoose://**  exe vamoose#push()
  " TODO: add a FileReadCmd autocommand.
augroup END
