# =========
# gdb.gdb
# =========
set confirm off
set pagination off
set print pretty on
set print frame-arguments all
set print elements 0
set print inferior-events off
set breakpoint pending on
set follow-fork-mode parent
set detach-on-fork on

set args -i ./bad.sh

# debug toggles
set $dl_wp_enabled = 0
set $dl_reran = 0

# Load helpers so show_ds is available even before arming
source gdb-watchpoints.gdb

define dl_print_ctx
  set $dl_base = (const char*)$arg0
  set $dl_st   = (int)$arg1
  set $dl_cur  = (int)$arg2
  set $dl_rad  = ($argc >= 4) ? (int)$arg3 : 16
  if $dl_base == 0
    printf "context: <null base>\n"
  else
    set $dl_lo = ($dl_st > $dl_rad) ? $dl_st - $dl_rad : 0
    printf "start=%d current=%d\n", $dl_st, $dl_cur
    printf "context: "
    printf "%.40s\n", $dl_base + $dl_lo
  end
end

# Capture the real history input buffer early
tbreak history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string
  set $dl_line = string
  printf "qc (start) = %d '%c'\n", qc, (char)qc
  printf "history_quoting_state (start) = %d\n", history_quoting_state
  printf "history_quotes_inhibit_expansion = %d\n", history_quotes_inhibit_expansion
  printf "history_expansion_char = '%c'\n", (char)history_expansion_char
  show_ds
  continue
end

# Parser calls into history
tbreak pre_process_line
commands
  silent
  printf "\n-- pre_process_line call --\n"
  bt 10
  continue
end

# Show correct context from the real line on error
tbreak hist_error
commands
  silent
  printf "\n== HIT hist_error ==\n"
  dl_print_ctx $dl_line start current 16
  printf "history_quoting_state (at error) = %d\n", history_quoting_state
  printf "history_quotes_inhibit_expansion = %d\n", history_quotes_inhibit_expansion
  show_ds
  bt 8

  # Arm watchpoints only once (re-source after flipping the flag)
  if $dl_wp_enabled == 0
    set $dl_wp_enabled = 1
    source gdb-watchpoints.gdb
  end
  continue
end

