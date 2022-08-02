#!/bin/bash
#SOURCEDIRS="bin Documents lib Maildir public_html .certs .config .easytag .gqview/collections .kde .linuxcounter .loki .pan2 .spamassassin .ssh .vmware"
#SOURCEFILES=".bashrc .face.icon .procmailrc .profile .vimrc DIRCOLORS logo_linux.png logo.png"
SOURCEDIRS="."
EXCLUDE=$HOME/lib/$( basename $0 .sh ).exclude
#TARGET="/media/MOLOK/${USER}"
#TARGET="/home/yrjo/pCloudDrive/home"
TARGET="/media/yrjo/HUGE/pharlap/home"
if [ ! -d $TARGET ]; then
#    mkdir $TARGET
	exit 1
fi
#rsync -avH --delete --numeric-ids  Work Public/HOME/
cd $HOME
for ddir in $SOURCEDIRS; do
	echo "$ddir"
	time rsync -avH -l --delete --numeric-ids --delete-excluded --exclude-from=$EXCLUDE $ddir $TARGET #> /dev/null 2>&1
done

for ffile in $SOURCEFILES;do
	cp -pv $ffile $TARGET
done
exit
