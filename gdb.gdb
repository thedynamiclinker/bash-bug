# =========
# gdb.gdb
# =========

set confirm off
set pagination off
set print pretty on
set print frame-arguments all
set print elements 0
set breakpoint pending on

# Optional (fork noise control). If you want to follow the child shell:
set follow-fork-mode child
set detach-on-fork off
set print thread-events off

# --- helper: show the delimiter stack nicely
define show_ds
  printf "dstack.depth=%d ", dstack.delimiter_depth
  if (dstack.delimiter_depth > 0)
    printf "top='%c' stack=\""
    set $i = 0
    while $i < dstack.delimiter_depth
      printf "%c", ((char*)dstack.delimiters)[$i]
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

# --- callsite right before history expansion (line may shift with version)
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
  x/s dstack.delimiters
  show_ds
  bt 4
  continue
end

# --- when history expand actually runs
break history_expand_internal
commands
  silent
  printf "\n-- history_expand_internal --\n"
  printf "string=%.160s\n", string          # <== param is 'string', not 's'
  p qc
  printf "qc as char: '%c'\n", (char)qc
  continue
end

# --- watch who mutates the delimiter state
# depth changes (push/pop)
watch -l dstack.delimiter_depth
commands
  silent
  printf "\n** dstack.delimiter_depth changed -> %d **\n", dstack.delimiter_depth
  show_ds
  bt 3
  continue
end

# writes to first few delimiter slots (enough to see pushes)
# (Hardware watchpoints are limited; 3–4 is usually safe.)
watch -l ((char*)dstack.delimiters)[0]
commands
  silent
  printf "\n** dstack.delimiters[0] write **\n"
  show_ds
  bt 3
  continue
end
watch -l ((char*)dstack.delimiters)[1]
commands
  silent
  printf "\n** dstack.delimiters[1] write **\n"
  show_ds
  bt 3
  continue
end
watch -l ((char*)dstack.delimiters)[2]
commands
  silent
  printf "\n** dstack.delimiters[2] write **\n"
  show_ds
  bt 3
  continue
end

