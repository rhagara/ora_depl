#!/bin/bash          
#
## [ -d newdir ] && echo "Directory Exists" || mkdir newdir
## for i in $( ls ); 
#

#use global var for file seq. numbering
GI_INC=100

# build_gi <sql-file-name> <dst>
function build_gi_rollback() 
{	local filename="$1"/gi-rollback.sql
  ###echo "prompt ----------------------------------------;" >> "$filename"
	echo "prompt &&1/rollback/$2;" >> "$filename"
	echo "@@     &&1/rollback/$2 ;" >> "$filename"
	echo "prompt ----------------------------------------;" >> "$filename"
	###echo "prompt" >> "$filename"
	echo "" >> "$filename"
	#prompt &&1/111_KMP_REPORT_ONUS_IPM.sql;
	#@@     &&1/111_KMP_REPORT_ONUS_IPM.sql ;
	#prompt ----------------------------------------;
}

# start_gi <dst>
function start_gi_rollback() 
{	local filename="$1"/gi-rollback.sql
  mkdir -p "$1"
	echo "--!gi:v0.2.7:db.issue:rollback:" >> "$filename"
	echo "-- ***** THIS SCRIPT (IS) was not GENERATED BY \"gi\" *****" >> "$filename"
	echo "" >> "$filename"
  echo "prompt " >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt ***** START of rollback of $2 on $3 schema *****;" >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt " >> "$filename"
	echo "" >> "$filename"
}

# stop_gi <dst>
function stop_gi_rollback() 
{	local filename="$1"/gi-rollback.sql
	echo "commit;" >> "$filename"
	echo "" >> "$filename"
	echo "prompt" >> "$filename"
  echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt ***** END of rollback of $2 on $3 schema *****;" >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt" >> "$filename"
	echo "" >> "$filename"
}

# build_gi <sql-file-name> <dst>
function build_gi() 
{	local filename="$1"/gi.pdc
  if [ "$3" == "rbck" ]; then	  
	  filename="$1/gi-rollback.sql"
	else
	  filename="$1/gi-install.sql"
	fi
  ###echo "prompt ----------------------------------------;" >> "$filename"
	echo "prompt &&1/$2;" >> "$filename"
	echo "@@     &&1/$2 ;" >> "$filename"
	echo "prompt ----------------------------------------;" >> "$filename"
	###echo "prompt" >> "$filename"
	echo "" >> "$filename"
	#prompt &&1/111_KMP_REPORT_ONUS_IPM.sql;
	#@@     &&1/111_KMP_REPORT_ONUS_IPM.sql ;
	#prompt ----------------------------------------;
}

# start_gi <dst>
function start_gi() 
{	  
	if [ "$1" == "-r" ]; then		
    shift 1  
    start_gi_rollback "$1" "$2" "$3" 
	fi  
  mkdir -p "$1"
  local filename="$1"/gi-install.sql
	echo "--!gi:v0.2.7:db.issue:install:" >> "$filename"
	echo "-- ***** THIS SCRIPT (IS) was not GENERATED BY \"gi\" *****" >> "$filename"
	echo "" >> "$filename"
  echo "prompt" >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt ***** START of installation of $2 on $3 schema *****;" >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt" >> "$filename"
	echo "" >> "$filename"
#<<EOF
#--!gi:v0.2.6:db.issue:install:
#-- ***** THIS SCRIPT IS GENERATED BY "gi" *****
#
#prompt
#prompt ------------------------------------------------------------------------;
#prompt ***** START of installation of TBACPP-29 on PAYGT schema *****;
#prompt ------------------------------------------------------------------------;
#prompt
#EOF
}

# stop_gi <dst>
function stop_gi() 
{	
	if [ "$1" == "-r" ]; then		
    shift 1  
    stop_gi_rollback "$1" "$2" "$3" 
	fi  
  local filename="$1"/gi-install.sql
	echo "commit;" >> "$filename"
	echo "" >> "$filename"
	echo "prompt" >> "$filename"
  echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt ***** END of installation of $2 on $3 schema *****;" >> "$filename"
	echo "prompt ------------------------------------------------------------------------;" >> "$filename"
	echo "prompt" >> "$filename"
	###echo "" >> "$filename"
#
#commit;
#
#prompt
#prompt ------------------------------------------------------------------------;
#prompt ***** END of installation of TBACPP-29 on PAYGT schema *****;
#prompt ------------------------------------------------------------------------;
#prompt
}

# cp <src> <dst>
function my_cp() 
{	
	# make sure filename supplied as command line arg else die
	[ $# -lt 2 ] && { echo "1Usage: $0 <SRC> <DST> (gi_inc) (rbck)"; exit 1; }

	local SRC=""
	if [ -f "$1" ]; then SRC="$1"; 
	elif [ -f "$1.sql" ]; then SRC="$1.sql"; 
	elif [ -f "$1.pkg" ]; then SRC="$1.pkg"; 
	elif [ -f "$1.pck" ]; then SRC="$1.pck"; 
	else 
	  [ ! -z "$3" ] && { let "GI_INC += 1"; }
	  return 0; 
	fi
	echo "CP : $SRC > $GI_INCREMENTAL $2"; 
	
	local GI_INCREMENTAL="$3"
	
	if [[ -z $GI_INCREMENTAL ]]; then
		if [[ -z $SRC ]]; then return 0; fi
		#cp "$SRC" "$2"; 
		sed '/--workaround\ SHOW\ ERRORS/,$d' "$SRC" > "$2/$SRC";
		
		#if [ "$4" == "gi0" ]; then	  
		#  build_gi "$2" "$SRC" 
		#fi
		
		return 0;
	else
		let "GI_INC += 1"
		if [[ -z $SRC ]]; then return 0; fi
		#cp "$SRC" "$2"/"$GI_INC"_"$SRC"; 
		sed '/--workaround\ SHOW\ ERRORS/,/\//d' "$SRC" > "$2"/"$GI_INC"_"$SRC"; 
		
		if [ "$4" == "rbck" ]; then	  
		  build_gi_rollback "$2/.." "$GI_INC"_"$SRC" "$4"
		else
		  build_gi "$2" "$GI_INC"_"$SRC" 
		fi
		
##		let "GI_INC -= 1"
		return 0;
	fi	
}

#
# (svn|gi) <SRC> <DST>
#
function cp_depl_deli() 
{
	# make sure filename supplied as command line arg else die
	[ $# -lt 4 ] && { echo "1Usage: cp_depl_deli $0 (svn|gi|gi0) <SRC> <DST> <file list>"; exit 1; }

	local SRCD="$2"
	local TGTD="$3"
	local GII="$GI_INC"
	
	echo ""
	echo "---------------------------------------------------"
	echo "(svn|gi|gi0):$1"
	echo "SRC:$SRCD"
	echo "TGT:$TGTD"
	echo "GI_INCREMENTAL:$GI_INCREMENTAL"
	echo "-----------------"
		
	local GI_INCREMENTAL=""
	if [ "$1" == "svn" ]; then
		GI_SVN="svn"
	elif [ "$1" == "gi" ]; then
		GI_SVN="gi"
	elif [ "$1" == "gi0" ]; then
		GI_SVN="gi"
		GI_INCREMENTAL=999
	else
		echo "2Usage: $0 (svn|gi) <SRC> <DST> <file list>"; 
		echo "$1"
		exit 1;
	fi
	shift 3 

	cd "$SRCD"
	mkdir -p "$TGTD"

#	ls -l "$SRCD"/"$1"*
#	ls -l "$TGTD"/"$1"*
	
	for i ###
	do	
	  my_cp "$i" "$TGTD" "$GI_INCREMENTAL" "$1"		
	done	

	cd "$TGTD"
##	sed 's/--workaround[\r\n\]+create or replace package tmp is n number; end;[\r\n\]+\///g' *.*	
##	sed 's/--workaround//repla/g' *.*
##	sed '/--workaround/,/\//d' 106_KMP_DEL.sql

### !!! toto nefungovalo ked som zacal lopirovat z svn lokality
	GI_INC="$GII"
	if [ "$GI_SVN" == "gi" ]; then
		if [[ -d "$SRCD/rollback" ]]; then
			echo "-----------------"
			echo "-- rollback"
			mkdir -p "$TGTD/rollback"
			cd "$SRCD/rollback"
			###cp "$SRCD/rollback/* "$TGTD"/rollback
			pwd
			###ls -l
			
			for j do 			  
			  my_cp "$j" "$TGTD/rollback" "$GI_INCREMENTAL" "rbck";
			done	
		fi	
	fi
	echo "-----------------"
}
