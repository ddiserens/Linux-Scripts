#!/bin/bash
################################################################################
# "SEC_Baseline.sh" - Daniel Diserens <diserens@gdls.com>
# Version 1.0
################################################################################
#  DESCRIPTION: This script will modify inittab to require a password before   #
#  booting into single user mode.                                              #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.           #
################################################################################
# set -x

#*******************************************************************************

#Variables
export DIR="/var/tmp/compliancecheck"
. "${DIR}/lib/setup.lib"
set_variables

. "${UTILDIR}/test/SEC_Run.sh"

#*******************************************************************************

#Functions
print_help () 
{
echo ""
echo "Usage: $0 [OPTION]"
echo ""
echo "Arguments:"
echo "	or: $0 -a, --all		Runs a check then fixes all the errors"
echo "	or: $0 -c, --check	Runs a check on the system"
echo "	or: $0 -f, --fix		Runs a through every fix"
echo "	or: $0 -r, --restore	Restores settings back to what they were before the program was ran"
echo "	or: $0 -h, --help"
}

#*******************************************************************************

case "$1" in
	-a|--all)
		RUN_TYPE="Complete"
		if [ ! -f ${CHECK_DIR} ]; then
        		mkdir -p ${CHECK_DIR}
		fi
		if [ ! -f ${FIX_DIR} ]; then
        		mkdir -p ${FIX_DIR}
		fi
                if [ ! -f ${EXCEPTION_DIR} ]; then
                        mkdir -p ${EXCEPTION_DIR}
                fi
		SEC_Run
		;;
	-c|--check)
		RUN_TYPE="Check"
		if [ ! -f ${CHECK_DIR} ]; then
        		mkdir -p ${CHECK_DIR}
		fi
		SEC_Run
		;;
	-f|--fix)
		RUN_TYPE="Fix"
		if [ ! -f ${FIX_DIR} ]; then
        		mkdir -p ${FIX_DIR}
		fi
		SEC_Run
		;;
	-r|--restore)
		RUN_TYPE="Restore"
		if [ ! -f ${RESTORE_DIR} ]; then
        		mkdir -p ${RESTORE_DIR}
		fi
		SEC_Run $2
		;;
	*)
		print_help
		exit 1
		;;
esac

