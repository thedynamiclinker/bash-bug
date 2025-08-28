# =========
# gdb.gdb
# =========
set pagination off
set print pretty on
set print frame-arguments all
set follow-fork-mode parent
set detach-on-fork on
#layout src

# init guard for watchpoints file
set $dl_wp_enabled = 0

# --- Prove we’re taking the history path (like your simple script) ---

# Stop right where the error is reported
break lib/readline/histexpand.c:388
commands
    silent
    backtrace
    return
    return
    return
    return
    printf "\n== HIT hist_error ==\n"
    # arm phase 2 after this first hit
    source gdb-watchpoints.gdb
    #continue
end

# Also stop at start of history expansion to see the input + qc
tbreak history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string
  p qc
  printf "qc as char: '%c'\n", (char)qc
  continue
end

# Catch the call site even if the exact line moves
tbreak pre_process_line
commands
  silent
  printf "\n-- pre_process_line call --\n"
  bt 10
  continue
end

