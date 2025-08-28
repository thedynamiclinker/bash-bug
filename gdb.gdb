# =========
# gdb.gdb
# =========
set confirm off
set pagination off
set print pretty on
set print frame-arguments all
layout src

define show_ds
  set $depth = dstack.delimiter_depth
  printf "dstack.depth=%d ", $depth
  if ($depth > 0)
    set $top = ((unsigned char*)dstack.delimiters)[$depth-1]
    printf "top='%c' stack=\"", (char)$top
    set $i = 0
    while ($i < $depth)
      set $ch = ((unsigned char*)dstack.delimiters)[$i]
      if ($ch >= 32 && $ch < 127)
        printf "%c", (char)$ch
      else
        printf "\\x%02x", $ch
      end
      set $i = $i + 1
    end
    printf "\"\n"
  else
    printf "top=<none>\n"
  end
end
document show_ds
  Print delimiter stack depth and content (top is depth-1).
end


break lib/readline/histexpand.c:388
commands
    silent
    backtrace
    return
    return
    return
    return
    p shell_input_line
    p shell_input_line_len
    p interactive_shell
    p remember_on_history
    p history_quoting_state
    p parser_state
    p bash_input.type
    p bash_input.location
    show_ds
    bt 4
end

