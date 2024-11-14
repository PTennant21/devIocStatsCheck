#!/usr/bin/bash

echo -e "Type your IOC directory. \c"
read EPICS_IOCS
#EPICS_IOCS="/epics/iocs"

echo -e "Type the name of your IOC. \c "
read IOC
#IOC="istats"

errors=7
missing=0

echo "Searching the in '$EPICS_IOCS/$IOC'"

if [ -d "$EPICS_IOCS/$IOC" ]; then

	# Checking for IOCADMIN set in configure/RELEASE
	case `grep -F "IOCADMIN=" "$EPICS_IOCS/$IOC/configure/RELEASE" &> /dev/null; echo $?` in
		0)
			echo "IOCADMIN set in $EPICS_IOCS/$IOC/configure/RELEASE"
			((errors--))
			;;
		1)
			echo "[WARNING] IOCADMIN not set in $EPICS_IOCS/$IOC/configure/RELEASE"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/configure/RELEASE not found"
			((missing++))
			;;
	esac

	# Checking for IOCADMIN set in envPaths
	case `grep -F "epicsEnvSet(\"IOCADMIN\"" "$EPICS_IOCS/$IOC/iocBoot/ioc$IOC/envPaths" &> /dev/null; echo $?` in
		0)
			echo "IOCADMIN set in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/envPaths"
			((errors--))
			;;
		1)
			echo "[WARNING] IOCADMIN not set in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/envPaths"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/envPaths not found"
			((missing++))
			;;
	esac

	# Checking for iocAdminSoft.db added to DB in $EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile
	case `grep -Fx "DB += $""(IOCADMIN)/db/iocAdminSoft.db" "$EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile" &> /dev/null; echo $?` in
		0)
			echo "iocAdminSoft added in $EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile"
			((errors--))
			;;
		1)
			echo "[WARNING] iocAdminSoft not added in $EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/"$IOC"App/Db/Makefile not found"
			((missing++))
			;;
	esac

	# Checking for iocAdminSoft.db in $EPICS_IOCS/$IOC/db
	if [ -e "$EPICS_IOCS/$IOC/db/iocAdminSoft.db" ]; then
		echo "$EPICS_IOCS/$IOC/db/iocAdminSoft.db exists"
		((errors--))
	else
		echo "[WARNING] $EPICS_IOCS/$IOC/db/iocAdminSoft.db does not exist"
		((missing++))
	fi
	
	# Checking for iocAdminSoft.db loaded in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd
	case `grep -Fx "dbLoadRecords(\"db/iocAdminSoft.db\", \"IOC=istats\")" "$EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd" &> /dev/null; echo $?` in
		0)
			echo "iocAdminSoft loaded in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd"
			((errors--))
			;;
		1)
			echo "[WARNING] iocAdminSoft not loaded in $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/iocBoot/ioc$IOC/st.cmd not found"
			((missing++))
			;;
	esac

	# Checking for iocAdmin.DBD added to "$IOC"_DBD in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile
	case `grep -Fx ""$IOC"_DBD += iocAdmin.dbd" "$EPICS_IOCS/$IOC/"$IOC"App/src/Makefile" &> /dev/null; echo $?` in
		0)
			echo "iocAdminSoft added in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile"
			((errors--))
			;;
		1)
			echo "[WARNING] iocAdminSoft not added in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile not found"
			((missing++))
			;;
	esac
	
	# Checking for devIocStats added to "$IOC"_LIBS in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile
	case `grep -Fx ""$IOC"_LIBS += devIocStats" "$EPICS_IOCS/$IOC/"$IOC"App/src/Makefile" &> /dev/null; echo $?` in
		0)
			echo "devIocStats added in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile"
			((errors--))
			;;
		1)
			echo "[WARNING] devIocStats not added in $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile"
			;;
		*)
			echo "[WARNING] $EPICS_IOCS/$IOC/"$IOC"App/src/Makefile not found"
			;;
	esac
	
	if [ $missing -eq 0 ]; then
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
	echo "$EPICS_IOCS/$IOC does not exist"
fi
