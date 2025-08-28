# =======
# BUG.gdb
# =======

# Don't stop for these breakpoints, just log
set pagination off
set print pretty on
set print frame-arguments all
layout src

break lib/readline/histexpand.c:388
commands
    silent
    backtrace
    return
    return
    return
    return
end
