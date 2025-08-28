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

# ---- helpers ---------------------------------------------------------

define dl_print_ctx
  # $arg0 = base char* (the real line buffer)
  # $arg1 = start index (int)
  # $arg2 = current index (int)
  # $arg3 = radius (int, optional; default 16)
  set $dl_base = (const char*)$arg0
  set $dl_st   = (int)$arg1
  set $dl_cur  = (int)$arg2
  set $dl_rad  = ($argc >= 4) ? (int)$arg3 : 16
  if $dl_base == 0
    printf "context: <null base>\n"
  else
    set $dl_lo = ($dl_st > $dl_rad) ? $dl_st - $dl_rad : 0
    set $dl_hi = $dl_cur + $dl_rad
    set $dl_len = $dl_hi - $dl_lo
    if $dl_len < 0
      set $dl_len = 0
    end
    printf "start=%d current=%d\n", $dl_st, $dl_cur
    printf "context: "
    # GDB printf supports precision; this bounds the slice
    printf "%.*s", $dl_len, $dl_base + $dl_lo
    printf "\n"
  end
end

# ---- capture the true history input buffer early ---------------------

tbreak history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string
  # Capture the real input line for later 'hist_error' use
  set $dl_line = string
  set $dl_qc = qc
  printf "qc as char: '%c'\n", (char)$dl_qc
  continue
end

# Pre-process line entry (parser calls into history)
tbreak pre_process_line
commands
  silent
  printf "\n-- pre_process_line call --\n"
  bt 10
  continue
end

# ---- error hook: show correct context from the real line --------------

tbreak hist_error
commands
  silent
  printf "\n== HIT hist_error ==\n"
  # 'start'/'current' are indices in the history scanning buffer,
  # so print context around those indices using the captured real line.
  dl_print_ctx $dl_line start current 16
  bt 12

  # Arm watchpoints only once and optionally re-run to catch early writes
  if $dl_wp_enabled == 0
    source gdb-watchpoints.gdb
    set $dl_wp_enabled = 1
    if $dl_reran == 0
      set $dl_reran = 1
      run
    end
  end
  continue
end

