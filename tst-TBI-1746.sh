#!/bin/bash          
#
## [ -d newdir ] && echo "Directory Exists" || mkdir newdir
## for i in $( ls ); 
#
#76.7.0 TBACQ KMU (batch)
#REL-2210
#TBACPP-29
ROOT="/cygdrive/c/work/svn"
REL="rel-78.0.0"
ISSU="TBI-1746"
SVN_BATCH_REL="rel-78"


DEVD="$ROOT/_develop/VF_Projects"/"TBI-1746_KK2.0_Birthday_Cashback_Automation"
SVND="$ROOT"/"_db_cms"
##SVND="$ROOT"/"_db_cms_br_TBACPP"

#SVND_BATCH="$ROOT"/"_cmsdd/batch/branches/$SVN_BATCH_REL/shell"
#SVND_BATCH="$ROOT"/"_batch/branches/$REL"
SVND_BATCH="$ROOT"/"_batch/trunk/shell"

DLVR="$ROOT/_Deliver/$ISSU"


##SRCD="$DEVD/paygt"
##SRCD="$SVND/db/paygt/branches/$REL/packages"
##TGTD="$DLVR/db/paygt/$ISSU"
##TGTD="$SVND/paygt/tables"


#ddl - new tables
TABLES0="EN_TXN_W4" 
TABLES="BCB_ACCOUNT_WRK BCB_PAYMENTS_WRK" 
SEQUENCES="seq_bcb_payments_id"

#ddl - alter tables
TABLES2=""

#dml tables - 
TABLES3="" 

PACKAGES0="" 
PACKAGES="PGP_BIRTHDAY_CASHBACK.pck"

VIEWS=""

UNIX=""

#include delivery library:
. ~/deliver_lib.sh
##uses GI_INC global variable for numbering

# #############################################################################
# unit test mock

# cp <src> <dst>
# unit test mock
function my_cp0() 
{
	[ -f "$1" ] && { echo "$1"; return 0; } 
	[ -f "$1.sql" ] && { echo "$1.sql"; return 0; } 
	[ -f "$1.pkg" ] && { echo "$1.pkg"; return 0; } 
}

# cp <src> <dst> ()
### function my_cp() 

#
### function cp_depl_deli() 

echo ""
echo "---------------------------------------------------"
echo "ISSU:$ISSU"
echo "REL :$REL"
echo "ROOT:$ROOT"
echo "DLVR:$DLVR"
echo "DEVD:$DEVD"
echo "SVND:$SVND"
echo ""
echo "-----------------"

# clean gi delivery folder
[ -d "$DLVR" ] && { echo "cleanning DIR:$DLVR"; rm -fR "$DLVR"/*; } || { echo "no DIR cleaned"; };

# create gi delivery folder
[ ! -d "$DLVR" ] && { echo "creating DIR:$DLVR"; mkdir "$DLVR"; } || { echo "no DIR created"; };

#rm -fR "$DLVR"
#cd "$DLVR"

################################################################################
##svn 
# .\paygt
# .\db\paygt
#
### PAYGT:SVN
SRCD="$DEVD/paygt"

###TODO SKIP FOR REBUILD
cp_depl_deli svn "$SRCD" "$SVND/paygt/tables" $TABLES $TABLES0 
#cp_depl_deli svn "$SRCD" "$SVND/paygt/views" $VIEWS
cp_depl_deli svn "$SRCD" "$SVND/paygt/sequences" seq_bcb_payments_id
cp_depl_deli svn "$SRCD" "$SVND/paygt/packages" $PACKAGES 

################################################################################
##gi PAYGT:GI
##could be taken from DEV or from svn commit
SRCD="$DEVD/paygt"
TGTD="$DLVR/db/paygt/$ISSU"
start_gi -r "$TGTD" $ISSU PAYGT

GI_INC=100; cp_depl_deli gi0 "$SRCD" "$TGTD" $TABLES $TABLES0 
#GI_INC=150; cp_depl_deli gi0 "$SRCD" "$TGTD" $TABLES2
GI_INC=200; cp_depl_deli gi0 "$SRCD" "$TGTD" seq_bcb_payments_id

GI_INC=300; cp_depl_deli gi0 "$SRCD" "$TGTD" $PACKAGES 
### user:_sel_user_errors
GI_INC=998; cp_depl_deli gi0 "$ROOT/_develop/VF_todos" "$TGTD" "_sel_user_errors"
stop_gi -r "$TGTD" $ISSU PAYGT


#rollback
###SRCD="$DEVD/paygt"
###GI_INC=100; cp_depl_deli gi0 "$SRCD/rollback" "$TGTD/rollback" $PACKAGES KMP_REPORT_ONUS_IPM

### SysApp:GI
###parameters.sql
SRCD="$DEVD/sysapp"
TGTD="$DLVR/db/sysapp/$ISSU"
start_gi -r "$TGTD" $ISSU SysApp
GI_INC=100; cp_depl_deli gi0 "$SRCD" "$TGTD" procesos process par_parameters par_values
#not used: CLASS_STATUS_CONFIG
stop_gi -r "$TGTD" $ISSU SysApp
###

### dba:gi
#SRCD="$DEVD/dba"
##TGTD="$DLVR/db/dba/$ISSU"
TGTD="$DLVR/db/dba"
#start_gi "$TGTD" $ISSU DBA
cp_depl_deli gi "$DEVD/dba" "$TGTD" secure_DB_schemas.sql 
cp_depl_deli gi "$ROOT/_develop/VF_todos" "$TGTD" _sel_errors.sql
#stop_gi "$TGTD" $ISSU DBA
###

### doc:gi
TGTD="$DLVR/"; mkdir -p "$TGTD"
##cp_depl_deli gi "$DEVD" "$TGTD" "RN_TBI-1700 BMAIL.doc"
cp "$DEVD/RN_TBI-1746 BCB.doc" "$TGTD"
###

################################################################################
##svn gi SHELL 
# .\scripts 
# c:\work\svn\_cmsdd\batch\branches\rel-72\shell\opt\cms\scripts 
# .\batch\scripts 
#
#SVND_BATCH="$ROOT"/"_cmsdd/batch/branches/$SVN_BATCH_REL/shell"
#SVND_BATCH="$ROOT"/"_batch/branches/$REL/shell"
#

# shell_opt_cms_scripts cmsapp
shell_opt_cms_scripts="KMU.ksh kmu_exec_procedures"
SRCD="$DEVD/scripts"
###SRCD="$DEVD/shell_opt_cms_scripts"
TGTD="$SVND_BATCH/opt/cms/scripts"
###TGTD="$SVND/batch/branches/$REL/shell/opt/cms/scripts"
#cp_depl_deli svn "$SRCD" "$TGTD" "$shell_opt_cms_scripts"
TGTD="$DLVR/batch/scripts"
#cp_depl_deli gi "$SRCD" "$TGTD" "$shell_opt_cms_scripts"


# shell_opt_cms_scripts_drauto cmsapp
shell_opt_cms_scripts_drauto="birthday_bonus.ksh"
SRCD="$DEVD/shell_opt_cms_scripts_drauto"
TGTD="$SVND_BATCH/opt/cms/scripts/drauto"
cp_depl_deli svn "$SRCD" "$TGTD" "$shell_opt_cms_scripts_drauto"
TGTD="$DLVR/batch/scripts/drauto"
#opt/cms
cp_depl_deli gi "$SRCD" "$TGTD" "$shell_opt_cms_scripts_drauto"


# shell_drauto_cmsap cmsap
shell_drauto_cmsap="TSCBDBS.sh"
SRCD="$DEVD/shell_drauto_cmsap"
TGTD="$SVND_BATCH/drauto/cmsap"
cp_depl_deli svn "$SRCD" "$TGTD" "$shell_drauto_cmsap"
TGTD="$DLVR/batch/drauto/cmsap"
cp_depl_deli gi "$SRCD" "$TGTD" "$shell_drauto_cmsap"

# shell_drauto_cmsap_PC_cfg cmsap
#From: 	batch/drauto/cmsap/PC/cfg/
#Into: 	/drauto/cmsap/PC/cfg/ 
shell_drauto_cmsap_PC_cfg="api_monthly_group_1.tasks"
SRCD="$DEVD/shell_drauto_cmsap_PC_cfg"
TGTD="$SVND_BATCH/drauto/cmsap/PC/cfg"
cp_depl_deli svn "$SRCD" "$TGTD" "$shell_drauto_cmsap_PC_cfg"
TGTD="$DLVR/batch/drauto/cmsap/PC/cfg"
cp_depl_deli gi "$SRCD" "$TGTD" "$shell_drauto_cmsap_PC_cfg"


# mk dir script
shell_standard_dat="gi-install.ksh"
SRCD="$DEVD/shell_standard_dat"
TGTD="$DLVR/batch/standard/dat"
## no SVN 
## cp_depl_deli gi "$SRCD" "$TGTD" "$shell_standard_dat"


cd "$ROOT/_db_cms_br_TBACPP"


################################################################################
##
# list gi delivery folder - usefull as imput for RN 
echo ""
echo "---------------------------------------------------"
echo "list gi delivery folder - usefull as imput for RN"
echo "---------------------------------------------------"
cd "$DLVR"
pwd
ls -R -1


################################################################################
exit 0;
################################################################################


################################################################################
##
# run gi in delivery folders
shopt -s expand_aliases

SCHEMAS="paygt acquirer cms bmail_new tb_bmail disco tb_ods_acqr tb_ods_cms tb_ods_paygt tb_ods_bmail tb_ods_disco"
FOLDERS="standard/acqrbin standard/bin scripts scripts/drauto drauto/cmsap drauto/cmsap/PC/cfg standard/dat/backup"

echo ""
echo "---------------------------------------------------"
echo "run $GI_SVN"
#cd "$DLVR/db"
cd db

pwd
for d in $SCHEMAS
do	
  [ -d "$d" ] && {  for i in $( ls "$d" ); do [ -d "$d" ]&&{ echo "$d/$i"; cd "$d/$i"; gi; cd ../..; }; done } #gi; 
done
	
#cd "$DLVR/batch"
cd "../batch"
pwd
for d in $FOLDERS 
do
  [ -d "$d" ] && { echo "$d"; cd "$d"; gi; cd ..; } #gi;
done

exit 0;
-----------------------------------------------------
