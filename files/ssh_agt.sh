#!/usr/bin/env bash
# Pewnie warto to sourceować w jakimś profilu.
if [[ -ne "$SSH_AUTH_SOCK" ]]
then
	# Ktoś już ustawił agenta ssh. Pewnie sesja Gnome.
	echo Załadowane klucze ssh:
	ssh-add -l
else
	case $- in
	*i*)    # interaktywnyshell
		if [[ -f ~/.ssh-agt-cfg ]]
		then
	        	pid=`grep PID ~/.ssh-agt-cfg | tr -d '"'| cut -f 2 -d '='`
	        	# sprawdzam czy SSH_AGENT_PID podany w pliku kontrolnym wskazuje na istniejący proces
	        	ps -p $pid > /dev/null
	        	if [[ $? -ne 0 ]]               # Trup w szafie
	        	then
	                	# trzeba odpalić nowy proces ssh-agent
	                	eval $(ssh-agent -s)
	                	ssh-add 	# To dodaje wszystkie klucze i w razie potrzeby pyta o hasła
	                	echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK > ~/.ssh-agt-cfg
	                	echo SSH_AGENT_PID=$SSH_AGENT_PID >> ~/.ssh-agt-cfg
	        	else
	                	source ~/.ssh-agt-cfg
	                	export SSH_AUTH_SOCK
	                	export SSH_AGENT_PID
	                	ssh-add -l
	        	fi
		else
	        	# need to launch new ssh-agent instance and save the config
	       		eval $(ssh-agent -s)
	        	ssh-add ~/.ssh/id_ecdsa
	        	ssh-add ~/.ssh/id_rsa
	        	echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK > ~/.ssh-agt-cfg
	        	echo SSH_AGENT_PID=$SSH_AGENT_PID >> ~/.ssh-agt-cfg
		fi
	;;
	*)      # non-interactive shell
		return
	;;
	esac
fi
