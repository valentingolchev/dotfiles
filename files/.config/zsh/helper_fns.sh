#!/bin/sh

function set_machine_env {
	unameOut="$(uname -s)"
	case "${unameOut}" in
	    Linux*)     machine=Linux;;
	    Darwin*)    machine=Mac;;
	    CYGWIN*)    machine=Cygwin;;
	    MINGW*)     machine=MinGw;;
	    MSYS_NT*)   machine=MSys;;
	    *)          machine="UNKNOWN:${unameOut}"
	esac
	export MACHINE_TYPE="$machine"
}

function is_macos {
  if [[ $MACHINE_TYPE == 'Mac' ]]; then
    echo true
  else
    echo false
  fi
}
