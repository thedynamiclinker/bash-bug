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
set $dl_wp_enabled = 0
set $reran = 0

tbreak history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string
  p qc
  printf "qc as char: '%c'\n", (char)qc
  continue
end

tbreak pre_process_line
commands
  silent
  printf "\n-- pre_process_line call --\n"
  bt 10
  continue
end

tbreak hist_error
commands
  silent
  printf "\n== HIT hist_error ==\n"
  # print a small excerpt around the bang
  set $s = s
  set $st = start
  set $cur = current
  set $lo = ($st > 16) ? $st - 16 : 0
  set $hi = $cur + 16
  printf "start=%d current=%d\n", $st, $cur
  printf "context: "
  printf "%.*s", $hi - $lo, $s + $lo
  printf "\n"
  bt 20
  if $dl_wp_enabled == 0
    source gdb-watchpoints.gdb
    set $dl_wp_enabled = 1
    if $reran == 0
      set $reran = 1
      run
    end
  end
  continue
end

