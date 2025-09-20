echo "$(case a in b) echo 'hi!';; esac)"
echo '================================='
echo "$(if false; then echo 'hi!'; fi)"
echo '================================='
echo $(case a in b) echo 'hi!';; esac)
echo '================================='
echo $(if false; then echo 'hi!'; fi)
