# =========
# gdb.gdb
# =========
set confirm off
set pagination off
set print pretty on
set print frame-arguments all
set print elements 0
set breakpoint pending on

# stay in the parsing parent; detach from children to cut noise
set follow-fork-mode child
set detach-on-fork on

# init guard for watchpoints file
set $dl_wp_enabled = 0

# --- Prove we’re taking the history path (like your simple script) ---

# Stop right where the error is reported
tbreak hist_error
commands
  silent
  printf "\n== HIT hist_error ==\n"
  bt 20
  # arm phase 2 after this first hit
  source gdb-watchpoints.gdb
  continue
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

