#!/bin/bash          
#
## [ -d newdir ] && echo "Directory Exists" || mkdir newdir
## for i in $( ls ); 
#
#76.7.0 TBACQ KMU (batch)
#REL-2210
#TBACPP-29
ROOT="/cygdrive/c/work/svn"
REL="rel-76.7.0"
ISSU="TBACPP-29"
SVN_BATCH_REL="rel-76"


DEVD="$ROOT/_develop/VF_Projects"/"TBACPP-29_TBACQ.in.W4&KMUreconciliation"
#SVND="$ROOT"/"_db_cms"
SVND="$ROOT"/"_db_cms_br_TBACPP"
SVND_BATCH="$ROOT"/"_cmsdd/batch/branches/$SVN_BATCH_REL/shell"
#SVND_BATCH="$ROOT"/"_batch/branches/$REL"

DLVR="$ROOT/_Deliver/$ISSU"

#ddl - new tables
TABLES0="EN_TXN_W4" 
TABLES="EN_XLDR_ENUMS EN_XLDR_PARAMS EN_XLDR_PARAM_NAMES" 

#ddl - alter tables
DDL_TABLES="EN_CHECKED_FILES EN_MATCHING EN_ARCHIV EN_PROGRAMS_OF_LOADER"

#dml tables - 
DML_TABLES="up_xldr_enums up_xldr_params up_xldr_param_names
            up_xldr_params_sms up_xldr_params_tc_visa2mc.sql" 

PACKAGES0="KMP_LUP KMP_UTL" 
PACKAGES="KMP_UTIL KMP_LOAD KMP_PREPARATION KMP_MATCHING KMP_CONFIRM KMP_DEL
          KMP_REP KMP_REP_ATM KMP_REP_ONUS KMP_REP_POS 
					KMP_REPORT_ISSR_IPM KMP_REPORT_POS_IPM KMP_REPORT_EURONET_IPM"
# KMP_REPORT_ONUS_IPM - just a drop obsolate pkg from TBI-1617
# KMP_REP_POS -

#ven_kmu_views.pdc 
VIEWS="ven_at_wn.sql ven_dat.sql ven_di_e.sql ven_epi.sql ven_sms_txna.sql ven_txna.sql 
       ven_txn_issr.sql ven_v_draft.sql ven_txna_w4.sql 
			 vem_epi_txna vem_v_draft_txna vem_di_e_txna
       vem_epi_txn_issr vem_v_draft_txn_issr
       vem_epi_txna_w4 vem_v_draft_txna_w4 vem_v_outga_txna_w4 vem_di_e_txna_w4
       ve_rollback.sql"
#vem_kmu_pos_matching_views.sql 
#vem_kmu_pos_matching_views_w4.sql
#vem_kmu_issr_matching_views.sql

UNIX="KMU.ksh kmu_exec_procedures"

#include delivery library:
. ~/deliver_lib.sh
##uses GI_INC global variable for numbering

# #############################################################################
# unit test mock
function gi() { return 0; }

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
# c:\work\svn\_cmsdd\db\paygt\branches\rel-72\packages\
# .\db\paygt
#
### PAYGT:SVN
SRCD="$DEVD/paygt"

###TODO SKIP FOR REBUILD
###cp_depl_deli svn "$SRCD" "$SVND/paygt/tables" $TABLES $TABLES0 

cp_depl_deli svn "$SRCD" "$SVND/paygt/views" $VIEWS
cp_depl_deli svn "$SRCD" "$SVND/paygt/packages" $PACKAGES $PACKAGES0 KMP_REP_POS

################################################################################
##gi PAYGT:GI
##could be taken from DEV or from svn commit
SRCD="$DEVD/paygt"
##SRCD="$SVND/db/paygt/branches/$REL/packages"
TGTD="$DLVR/db/paygt/$ISSU"; mkdir -p "$TGTD"
start_gi -r "$TGTD" $ISSU PAYGT

###TODO SKIP FOR REBUILD
GI_INC=100; cp_depl_deli gi0 "$SRCD" "$TGTD" $TABLES $TABLES0 
GI_INC=150; cp_depl_deli gi0 "$SRCD" "$TGTD" $DDL_TABLES
GI_INC=160; cp_depl_deli gi0 "$SRCD" "$TGTD" $DML_TABLES
GI_INC=200; cp_depl_deli gi0 "$SRCD" "$TGTD" $PACKAGES0
GI_INC=210; cp_depl_deli gi0 "$SRCD" "$TGTD" $VIEWS
GI_INC=300; cp_depl_deli gi0 "$SRCD" "$TGTD" $PACKAGES KMP_REPORT_ONUS_IPM
### user:_sel_user_errors
GI_INC=998; cp_depl_deli gi0 "$ROOT/_develop/VF_todos" "$TGTD" "_sel_user_errors"

stop_gi -r "$TGTD" $ISSU PAYGT


#rollback
###SRCD="$DEVD/paygt"
###GI_INC=100; cp_depl_deli gi0 "$SRCD/rollback" "$TGTD/rollback" $PACKAGES KMP_REPORT_ONUS_IPM

### SysApp:GI
#SRCD="$DEVD/sysapp"
#
###dml_ARP_WAY4_TRANSFER_ONUS dml_ARP_WAY4_TRANSFER_OFFUS 
#
TGTD="$DLVR/db/sysapp/$ISSU"; mkdir -p "$TGTD"
start_gi -r "$TGTD" $ISSU SysApp
GI_INC=100; cp_depl_deli gi0 "$DEVD/sysapp" "$TGTD" dml_ARP_KMU_ONUS dml_ARP_KMU_OFFUS dml_EN_PROGRAMS_OF_LOADER_ONUS dml_EN_PROGRAMS_OF_LOADER_OFFUS

stop_gi -r "$TGTD" $ISSU SysApp
###

### dba:gi
#SRCD="$DEVD/dba"
##TGTD="$DLVR/db/dba/$ISSU"; mkdir -p "$TGTD"
TGTD="$DLVR/db/dba"; mkdir -p "$TGTD"
#start_gi "$TGTD" $ISSU DBA
cp_depl_deli gi "$DEVD/dba" "$TGTD" secure_DB_schemas.sql 
cp_depl_deli gi "$ROOT/_develop/VF_todos" "$TGTD" _sel_errors.sql
#stop_gi "$TGTD" $ISSU DBA
###

### doc:gi
TGTD="$DLVR/"; mkdir -p "$TGTD"
##cp_depl_deli gi "$DEVD" "$TGTD" "RN_TBI-1700 BMAIL.doc"
cp "$DEVD/RN_TBACPP-29 KMU.doc" "$TGTD"
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
SRCD="$DEVD/scripts"
TGTD="$SVND_BATCH/opt/cms/scripts"
cp_depl_deli svn "$SRCD" "$TGTD" KMU.ksh kmu_exec_procedures
#TGTD="$DLVR/batch/scripts"
cp_depl_deli gi "$SRCD" "$DLVR/batch/scripts" KMU.ksh kmu_exec_procedures

# mk dir script
SRCD="$DEVD/shell_standard_dat"
TGTD="$DLVR/batch/standard/dat"
## no SVN ##cp_depl_deli svn "$SRCD" "$TGTD" gi-install.ksh
###cp_depl_deli gi "$SRCD" "$TGTD" gi-install.ksh


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
SRCD="$DEVD/shell_opt_cms_scripts"
TGTD="$SVND/batch/branches/$REL/shell/opt/cms/scripts"
cp_depl_deli svn "$SRCD" "$TGTD" AIM.ksh KMU.ksh kmu_exec_procedures
TGTD="$DLVR/batch/scripts"
cp_depl_deli gi "$SRCD" "$TGTD" AIM.ksh KMU.ksh kmu_exec_procedures

SRCD="$DEVD/shell_drauto_cmsap"
TGTD="$SVND/batch/branches/$REL/shell/drauto/cmsap"
cp_depl_deli svn "$SRCD" "$TGTD" cms_file_process_lib.cfg
TGTD="$DLVR/batch/drauto/cmsap"
cp_depl_deli gi "$SRCD" "$TGTD" cms_file_process_lib.cfg

# mk dir script
SRCD="$DEVD/shell_standard_dat"
TGTD="$DLVR/batch/standard/dat"
## no SVN ##cp_depl_deli svn "$SRCD" "$TGTD" gi-install.ksh
cp_depl_deli gi "$SRCD" "$TGTD" gi-install.ksh


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
