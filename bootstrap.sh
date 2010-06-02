#/bin/sh

CMYERS_ZSH_DEBUG=1
# This script bootstraps hdvcs.  I need it because in order to check out hdvcs I
# need my ssh keys (to check it out from github).

# should be run from the git repo that contains your home dir
CONFIG_FILE="$PWD/default/bin/hdvcs/hdvcs.conf"
SSH_FILES="$PWD/default/.ssh"

cp -r $SSH_FILES $HOME
chmod -R 600 ~/.ssh

cp $CONFIG_FILE "$HOME/.hdvcs.conf"

# ripped off of http://mah.everybody.org/docs/ssh#csh_login
SSH_ENV="$HOME/.ssh/environment"
SSHAGENT="/usr/bin/ssh-agent"
SSHADD="/usr/bin/ssh-add"
function start_agent {
     echo "Initialising new SSH agent..."
     $SSHAGENT | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     for i in `ls $HOME/.ssh/*-priv-*`; do $SSHADD $i; done
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    if [[ -n "$CMYERS_ZSH_DEBUG" ]]; then echo "Using existing ssh-agent"; fi
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | /bin/grep ${SSH_AGENT_PID} | /bin/egrep 'ssh-agent$' > /dev/null || {
    start_agent;
}
else
    if [[ -n "$CMYERS_ZSH_DEBUG" ]]; then echo "Creating new ssh-agent"; fi
    start_agent;
fi 

####
# these are the cmds that need .ssh to exist first
git submodule init
git submodule update
default/bin/hdvcs
