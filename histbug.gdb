# =======
# BUG.gdb
# =======

# Don't stop for these breakpoints, just log
set pagination off
set print pretty on
set print frame-arguments all

# Break at parse.y:2661 (the pre_process_line call)
break parse.y:2661
commands
  silent
  printf "\n--- parse.y:2661 pre_process_line ---\n"
  printf "remember_on_history=%d\n", remember_on_history
  printf "current_delimiter(dstack)='%c'\n", (char)current_delimiter(dstack)
  printf "history_quoting_state=%d\n", history_quoting_state
  backtrace
  continue
end

# Break when history expansion is called
break history_expand_internal
commands
  silent
  printf "\n--- history_expand_internal ---\n"
  printf "s=%.80s\n", s
  printf "qc=%d ('%c')\n", qc, qc
  continue
end
