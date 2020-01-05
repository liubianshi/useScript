#!/usr/bin/env bash

zshz () {
	emulate -L zsh
	setopt LOCAL_OPTIONS WARN_CREATE_GLOBAL
	local -A opts
	zparseopts -E -D -A opts -- -add -complete c e h -help l r t x
	if [[ $1 == '--' ]]
	then
		shift
	elif [[ -n ${(M)@:#-*} ]]
	then
		print "Improper option(s) given."
		_zshz_usage
		return 1
	fi
	local opt output_format method='frecency' fnd 
	for opt in ${(k)opts}
	do
		case $opt in
			(--add) _zshz_add_path "$*"
				return ;;
			(--complete) if [[ -s $datafile ]] && [[ ${ZSHZ_COMPLETION:-frecent} == 'legacy' ]]
				then
					_zshz_legacy_complete "$1"
					return
				fi
				output_format='completion'  ;;
			(-c) set -- "$PWD $*" ;;
			(-h | --help) _zshz_usage
				return ;;
			(-l) output_format='list'  ;;
			(-r) method='rank'  ;;
			(-t) method='time'  ;;
			(-x) _zshz_remove_path "$*"
				return ;;
		esac
	done
	fnd="$*" 
	[[ -n $fnd ]] && [[ $fnd != "$PWD " ]] || {
		[[ $output_format != 'completion' ]] && output_format='list' 
	}
	if [[ ${@: -1} == /* ]] && (( ! $+opts[-e] )) && (( ! $+opts[-l] ))
	then
		[[ -d ${@: -1} ]] && builtin cd ${@: -1} && return
	fi
	if (( $+ops[-c] ))
	then
		_zshz_find_matches "$fnd*" $method $output_format
	else
		_zshz_find_matches "*$fnd*" $method $output_format
	fi
	local ret2=$? 
	local cd
	read -rz cd
	if (( ret2 == 0 )) && [[ -n $cd ]]
	then
		if (( $+opts[-e] ))
		then
			print -- "$cd"
		else
			builtin cd "$cd"
		fi
	else
		return $ret2
	fi
}
