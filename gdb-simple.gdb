# =======
# gdb.gdb
# =======

set pagination off
set print pretty on
set print frame-arguments all
#layout src

b parse.y:2661
commands
    silent
    printf "\n-- parse.y:2661 pre_process_line --\n"
    p shell_input_line
    p shell_input_line_len
    p history_quoting_state
    p dstack.delimiter_depth
    p interactive_shell
    p remember_on_history
    p history_quoting_state
    p last_read_token
    p current_token
    p token_to_read
    p parser_state
    p bash_input.type
    p bash_input.location
    # show the stack memory (top is depth-1)
    x/s dstack.delimiters
    # show the top like the macro would

    # set write watches
    watch -l dstack.delimiter_depth
    # fires on first slot writes
    watch -l ((char*)dstack.delimiters)[0]

    if (dstack.delimiter_depth > 0)
        printf "current_delimiter = '%c'\n", ((char*)dstack.delimiters)[dstack.delimiter_depth-1]
    else
        printf "current_delimiter = <none>\n"
    end
    bt 4
    continue
end

#break lib/readline/histexpand.c:388
#commands
#    silent
#    backtrace
#    return
#    return
#    return
#    return
#end
#
