clear

##
# Color Variables
##

cRED="\033[0;31m"
cGREEN="\033[0;32m"
cBROWN="\033[0;33m"
cBLUE="\033[0;34m"
cPURPLE="\033[0;35m"
cCYAN="\033[0;36m"
cYELLOW="\033[1;33m"
cNC="\033[0m" # NO COLOR

# System Character SET
export CHARSET=UTF-8

# Default System langauge
export LANG=en.utf8

#
export PAGER=less

# Value and its permission level
#
# 0	---	No permission
# 1	--x	Execute
# 2	-w-	Write
# 3	-wx	Write and execute
# 4	r--	Read
# 5	r-x	Read and execute
# 6	rw-	Read and write
# 7	rwx	Read, write, and execute

# Default File permission
# Current
# [ folder ]  777 - 022 = 755
# [ file ]    666 - 022 = 644
umask 022

# Default Path Variables
export PATH=/usr/local/sbin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/usr/bin
export PATH=$PATH:/sbin
export PATH=$PATH:/bin

# setup custom paths
export PATH=$PATH:$LARAVEL_APPDIR/vendor/bin
export PATH=$PATH:$HOME/.composer/vendor/bin
export PATH=$PATH:$HOME/.bun/bin


# Info
# printf "$cBLUE"
# figlet -w 120 "LaraDock"
# echo "Laravel on Docker"
# printf "$cNC"

# # OS Info
# . /etc/os-release
# echo "$PRETTY_NAME `uname -m`"

# # Additional System Info
# echo "kernel:`uname -r` hostname:`uname -n` user:`whoami` "
# echo "PHP: v`php -r 'echo PHP_VERSION;'` "


### Aliases

alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

# custom alias for laravel
alias a='artisan'
alias ac='artisan-clear'
alias dump='composer-dump'



# Default Shell
NEWLINE=$'\n'
SHELL_CHAR="$"
SHELL_COLOR="$cGREEN"

# customize prompt if root
if [ `whoami` = 'root' ]; then
    SHELL_CHAR="#"
    SHELL_COLOR="$cRED"
fi
SHELL_CHAR="$SHELL_COLOR$SHELL_CHAR$cNC"
SHELL="$NEWLINE$SHELL_COLOR\u@$cNC$cBLUE\h$cNC [\w] $SHELL_CHAR "
export PS1="$SHELL"


# Custom user profile
USER_SHELL="~/.profile"
[ -f '$USER_SHELL' ] && source $USER_SHELL
