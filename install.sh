#!/bin/bash
# 
# script for release issue
#
# would be placed in folder following specific name convention 
# e.g. ~/Delivery/rel-72.0.0
# or script parameter should be used
#
# Usage: ./install.sh ~/Delivery/rel-73.0.0


#alias gi=~cmsmaster/apps/gi
. ~/.bashrc
shopt -s expand_aliases

SCHEMAS="sysapp paygt acquirer cms aim bmail_new tb_bmail disco tb_ods_acqr tb_ods_cms tb_ods_paygt tb_ods_bmail tb_ods_disco"
#        dba    paygt acquirer cms     bmail_new tb_bmail disco tb_ods_acqr tb_ods_cms tb_ods_paygt tb_ods_bmail tb_ods_disco

# make sure rel supplied as command line arg else die
[ $# -lt 1 ] && { echo "1Usage: $0 rel-nn.0.0"; exit 1; }

echo ""
echo "---------------------------------------------------"
if [[ -d "$1" ]]; then
	echo "run Install for release:: $1"	
	cd "$1"
	DLVR=$(pwd)
	echo "Running in >>> $DLVR <<<"
else
	echo "2Usage: $0 rel-nn.0.0"; 
	echo "$1"
	exit 1;
fi

#
#  should be placed in external include file
#  700
#  %1 .. DSURC, T1SURC, T2SURC, USURC, SURC
#
DB=DSURC
paygtUSR=PAYGT
paygtPWD=heslo
cmsUSR=CMS
cmsPWD=heslo
sysappUSR=TE072768
sysappPWD=

# 
# has to be invocated from ...
#
#  %1 rel...
#  %2 install / rollback
# 
###cd ./rel-74.5.0/db
pwd
ls -l

cd ./db/paygt

# paygt
cmd=rollback
if [[ $paygtPWD && -f "./gi-$cmd-PAYGT.sql" ]]; then
sqlplus $paygtUSR@$DB @./gi-$cmd-PAYGT.sql . <<EOF
$paygtPWD
EOF
fi
cmd=install
if [[ $paygtPWD && -f "./gi-$cmd-PAYGT.sql" ]]; then
sqlplus $paygtUSR@$DB @./gi-$cmd-PAYGT.sql . <<EOF
$paygtPWD
EOF
fi

exit

$paygtPWD
ip999999
10
pause

# cms
if [[ $cmsPWD && -f "./cms/gi-$cmd-CMS.sql" ]]; then
sqlplus $cmsUSR@$DB @./cms/gi-$cmd-CMS.sql <<EOF
$cmsPWD
EOF
fi

# sysapp
if [[ $sysappPWD && -f "./sysapp/gi-$cmd-SYSAPP.sql" ]]; then
sqlplus $sysappUSR@$DB @./sysapp/gi-$cmd-SYSAPP.sql <<EOF
$sysappPWD
EOF
fi


exit
###############################################################################
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