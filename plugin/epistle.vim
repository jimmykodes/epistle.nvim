if exists('g:loaded_epistle')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range EpistleNewFromSelection lua require('epistle').new_from_selection(<f-args>)
command! -nargs=* EpistleOpen lua require('epistle').open(<f-args>)
command! EpistleToday lua require('epistle').today()
command! EpistleFind lua require('epistle').find()

let g:loaded_epistle= 1
