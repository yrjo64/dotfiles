#!/bin/bash
COMMAND="mvn clean install -DskipTests"
DIRS=('main-pom' 'conversion-dataobjects' 'csvwriter' 'csvreader' 'prevalidator-utils' 'prevalidator-ruleresources' 'prevalidator')
pushd $PWD
pushd $HOME/workspace/mandatum/lainaturva
stat=0
for ddir in "${DIRS[@]}"; do
	pushd $ddir &> /dev/null
	echo
	echo -e "######################### \e[1m$ddir\e[0m"
	mvn clean install -DskipTests $@
	stat=$?
	if (($stat)); then
		echo -e "######################### $ddir compiled \e[31mhas errors\e[0m"
		break;
	else
		echo -e "######################### $ddir compiled \e[32msuccessfully\e[0m"
	fi
	popd &> /dev/null
done
popd
exit $stat
