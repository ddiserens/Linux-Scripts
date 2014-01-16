#!/bin/bash
# "1580_startup_perm.sh" - Daniel Diserens <diserens@gdls.com>
# Version 1.0
################################################################################
#  DESCRIPTION: This script will modify inittab to require a password before   #
#  booting into single user mode.                                              #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.           #
################################################################################
# set -x

#Variables
. "/var/tmp/compliancecheck/lib/setup.lib"
#set_variables 
check_rtc 1580_startup_perm.sh

C53FILE="/etc/rc.d/ /etc/init.d/"

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing permissions on startup files"
#Runs fix for STIG ID - GEN001580 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001580"
if [ "${STARTTOFIX}" = "" ]; then
	for FILES in ${C53FILE}; do
		PERMS=`stat -L --format='%04a' ${DIRTOFIX}`
		echo "chmod $PERMS $FILES" >> ${FIX_DIR}/GEN1580_perm.${PDATE}.fix
		chmod u-s,g-ws,o-wt #FILES
	done
else
	for FILES in ${STARTTOFIX}; do
		PERMS=`stat -L --format='%04a' ${DIRTOFIX}`
		echo "chmod $PERMS $FILES" >> ${FIX_DIR}/GEN1580_perm.${PDATE}.fix
		chmod u-s,g-ws,o-wt #FILES
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1580_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001580 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for DIR in ${C53FILE}; do
			STARTTOFIX="`find ${DIR} -type f -perm /7022` $STARTTOFIX"
		done
                if [[ "${STARTTOFIX}x" == "x" ]]; then
                        echo "GEN001580 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001580 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${STARTTOFIX}x" == "x" ]]; then
                        echo "GEN001580 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001580 - Failed" | tee -a ${COMPLIANCE}
                fi
                ;;
        "Fix")
                fix_system
                if [ $? != 0 ]; then
                        echo "Fix Failed" | tee -a ${FIX}
                        restore_system
                fi
                ;;
        "Restore")
                restore_system $1
                ;;
        "Exclude")
                exclude_system
                ;;
        *)
                echo "You have entered an invalid switch"
                exit 1
                ;;
esac
