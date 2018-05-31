#!/bin/bash
# 
# script for release build 
#
# would be placed in folder following specific name convention 
# e.g. ~/Delivery/rel-72.0.0
# or script parameter should be used
#
# Usage: ./build.sh ~/Delivery/rel-73.0.0


#alias gi=~cmsmaster/apps/gi
. ~/.bashrc
shopt -s expand_aliases

SCHEMAS="dba sysapp acquirer cms paygt aim disco bmail_new main_bmail sosa
         tb_ods_acqr tb_ods_cms tb_ods_paygt tb_ods_bmail tb_ods_disco"
##tb_bmail 

FOLDERS="standard/acqrbin standard/bin scripts scripts/drauto drauto/cmsap standard/dat/backup"
#
#        standard/dat/backup
#        standard/dat 
#        drauto/cmsap/PC/cfg
#

# make sure $rel supplied as command line arg else die
[ $# -lt 1 ] && { echo "1Usage: $0 rel-nn.0.0"; exit 1; }

echo ""
echo "---------------------------------------------------"
if [[ -d "$1" ]]; then
	echo "run GI for release:: $1"	
	cd "$1"
	DLVR=$(pwd)
	echo "Running in >>> $DLVR <<<"
else
	echo "2Usage: $0 rel-nn.0.0"; 
	echo "$1"
	exit 1;
fi

##
# run gi in delivery subfolders
echo ""
echo "---------------------------------------------------"
if [[ ! -d db ]]; then
	echo "warning: no db subfolder"
	pwd
else 	
	echo "run GI in db - schema / issue subfolders"
	#1 cd "$DLVR/db"
	cd db
	for d in $SCHEMAS
	do
	  if [[ -d "$d" ]]; then 
		echo "*schema::$d"; 
		cd "$d";
		for i in $( ls ); 
		do [ -d "$i" ] && { echo "**issue::$d/$i"; cd "$i"; gi db.$i; cd ..; }; 
		done #gi;
		[ -d "$i" ] && gi db.$d;
		cd ..;
	  fi
	done
	cd ..;
fi

echo ""
echo "---------------------------------------------------"
if [[ ! -d batch ]]; then
	echo "warning: no batch subfolder"
	pwd
else 	
	echo "run GI in batch subfolders"
	#2 
	#cd "$DLVR"
	cd batch
	for d in $FOLDERS 
	do
		[ -d "$d" ] && { echo "**$d"; cd "$d"; gi; cd "$DLVR"/batch; } 
	done 
	##
	pwd
	chmod 0750 "$DLVR"/batch/standard/dat/gi-install.ksh
	##
	cd ..;
fi	
