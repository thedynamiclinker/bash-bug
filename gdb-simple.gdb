# =======
# gdb.gdb
# =======

set pagination off
set print pretty on
set print frame-arguments all
set follow-fork-mode parent
set detach-on-fork on
layout src

break lib/readline/histexpand.c:388
#commands
#    silent
#    backtrace
#    return
#    return
#    return
#    return
#end
