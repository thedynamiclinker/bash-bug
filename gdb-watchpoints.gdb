# gdb-watchpoints.gdb
if $dl_wp_enabled == 1
  define show_ds
    set $dl_depth = dstack.delimiter_depth
    printf "dstack.depth=%d ", $dl_depth
    if ($dl_depth > 0)
      set $dl_top = ((unsigned char*)dstack.delimiters)[$dl_depth-1]
      printf "top='%c' stack=\"", (char)$dl_top
      set $dl_i = 0
      while ($dl_i < $dl_depth)
        set $dl_ch = ((unsigned char*)dstack.delimiters)[$dl_i]
        if ($dl_ch >= 32 && $dl_ch < 127)
          printf "%c", (char)$dl_ch
        else
          printf "\\x%02x", $dl_ch
        end
        set $dl_i = $dl_i + 1
      end
      printf "\"\n"
    else
      printf "top=<none>\n"
    end
  end

  break parse.y:2661
  commands
    silent
    printf "\n-- parse.y:2661 pre_process_line --\n"
    p shell_input_line
    p shell_input_line_len
    p interactive_shell
    p remember_on_history
    p history_quoting_state
    p (enum token)current_token
    p (enum token)last_read_token
    p parser_state
    p lex_state
    p bash_input.type
    p bash_input.location
    show_ds
    bt 5
    continue
  end

  watch -l dstack.delimiter_depth
  commands
    silent
    printf "\n** dstack.delimiter_depth -> %d **\n", dstack.delimiter_depth
    show_ds
    bt 3
    continue
  end

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

  watch -l history_quoting_state
  commands
    silent
    printf "\n** history_quoting_state -> %d **\n", history_quoting_state
    bt 2
    continue
  end
end

