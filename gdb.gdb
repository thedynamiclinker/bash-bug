# =========
# gdb.gdb
# =========
set confirm off
set pagination off
set print pretty on
set print frame-arguments all
set print elements 0
set breakpoint pending on

# Follow the child; keeps forks under control
set follow-fork-mode child
set detach-on-fork off
set print thread-events off

# ---- helper: dump delimiter stack nicely (handles non-printables)
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
  Print delimiter stack depth and content (top is depth-1). Non-printables as \xNN.
end

# ---- stop right before history expansion (adjust line if it moves)
break parse.y:2661
commands
  silent
  printf "\n-- parse.y:2661 pre_process_line --\n"
  p shell_input_line
  p shell_input_line_len
  p history_quoting_state
  p interactive_shell
  p remember_on_history
  p (enum token)current_token
  p (enum token)last_read_token
  p parser_state
  p lex_state
  p bash_input.type
  p bash_input.location
  show_ds
  bt 4
  continue
end

# ---- when history expansion actually runs
break history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string      # <-- param is 'string' in this tree
  p qc
  printf "qc as char: '%c'\n", (char)qc
  continue
end

# ---- watch who mutates the delimiter state
watch -l dstack.delimiter_depth
commands
  silent
  printf "\n** dstack.delimiter_depth changed -> %d **\n", dstack.delimiter_depth
  show_ds
  bt 3
  continue
end

# Watch first few slots; hardware watchpoints are limited, so 0..2 is plenty
watch -l ((unsigned char*)dstack.delimiters)[0]
commands
  silent
  printf "\n** dstack.delimiters[0] write **\n"
  show_ds
  bt 3
  continue
end

watch -l ((unsigned char*)dstack.delimiters)[1]
commands
  silent
  printf "\n** dstack.delimiters[1] write **\n"
  show_ds
  bt 3
  continue
end

watch -l ((unsigned char*)dstack.delimiters)[2]
commands
  silent
  printf "\n** dstack.delimiters[2] write **\n"
  show_ds
  bt 3
  continue
end

break lib/readline/histexpand.c:388
commands
    silent
    backtrace
    return
    return
    return
    return
end
