#!/usr/bin/bash

# Checks if argument 1 is found in argument 2. Argument 3 set to true if argument 2 has been searched previously.
check ()
{
	local condition=$1
	local path=$2
	local notrepeat=$3
	
	case `grep -F $condition $path &> /dev/null; echo $?` in
		0)
			echo "$condition found in $path"
			((errors--))
			;;
		1)
			echo "[WARNING] $condition not found in $path"
			;;
		*)
			echo "[WARNING] $path not found"
			if $notrepeat ; then
				((missing++))
			fi
			;;
	esac
}
errors=7
missing=0

echo "Beginning search in '$IOCBASE/$IOC'"

if [ -d "$IOCBASE/$IOC" ] && [ "$IOC" != "" ] && [ "$IOCBASE" != "" ]; then

	# Checking for IOCADMIN set in configure/RELEASE
	check "IOCADMIN" "$IOCBASE/$IOC/configure/RELEASE" true

	# Checking for IOCADMIN set in envPaths
	check "epicsEnvSet(\"IOCADMIN\"" "$IOCBASE/$IOC/iocBoot/ioc$IOC/envPaths" true

	# Checking for iocAdminSoft.db added to DB in $EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile
	check "iocAdminSoft.db" "$IOCBASE/$IOC/"$IOC"App/Db/Makefile" true

	# Checking for iocAdminSoft.db in $EPICS_IOCS/$IOC/db
	if [ -e "$IOCBASE/$IOC/db/iocAdminSoft.db" ]; then
		echo "$IOCBASE/$IOC/db/iocAdminSoft.db exists"
		((errors--))
	else
		echo "[WARNING] $IOCBASE/$IOC/db/iocAdminSoft.db does not exist"
		((missing++))
	fi
	
	# Checking for iocAdminSoft.db loaded in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd
	check "iocAdminSoft.db" "$IOCBASE/$IOC/iocBoot/ioc$IOC/st.cmd" true

	# Checking for iocAdmin.DBD added to "$IOC"_DBD in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile
	check "iocAdmin.dbd" "$IOCBASE/$IOC/"$IOC"App/src/Makefile" true
	
	# Checking for devIocStats added to "$IOC"_LIBS in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile
	check "devIocStats" "$IOCBASE/$IOC/"$IOC"App/src/Makefile" false
	
	if [ $errors -eq 0 ]; then
		echo "This IOC meets all devIocStats requirements"
	elif [ $errors -lt 7 ]; then
		echo "This IOC is missing $errors devIocStats requirements"
	else
		echo "This IOC does not meet any devIocStats requirements"
	fi

	if [ $missing -eq 6 ]; then
		echo "This IOC is missing all required files or directories"
	elif [ $missing -gt 0 ]; then
		echo "This IOC is missing $missing required files or directories"
	fi

else	
	echo "$IOCBASE/$IOC does not exist"
fi
