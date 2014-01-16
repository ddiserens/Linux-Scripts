#!/bin/bash
# "1360_nis_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1360_nis_perms.sh

C32FILE="/var/yp"
C32LINE=`find ${C32FILE} -type f -perm /7022`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Perform the following permissions on NIS file ownership"
#Runs fix for STIG ID - GEN001360 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001360"
if [ "${NISTOFIX}" = "" ]; then
	for NISFILE in ${C32LINE}; do
                NISPERMS=`stat -L --format='%04a' $NIS_FILE`
                echo "chmod $NISPERMS $NIS_FILE"
                chmod u-s,g-ws,o-wt $NIS_FILE
        done
else
	for NIS_FILE in ${NISTOFIX};do 
		NISPERMS=`stat -L --format='%04a' $NIS_FILE`
		echo "chmod $NISPERMS $NIS_FILE"
		chmod u-s,g-ws,o-wt $NIS_FILE
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1360_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001360 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for NISFILE in ${C32LINE}; do
			NISTOFIX="$NISFILE NISTOFIX"
		done

                if [[ "${NISTOFIX}x" == "x" ]]; then
                        echo "GEN001360 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001360 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001360 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for NISFILE in ${C32LINE}; do
                        NISTOFIX="$NISFILE NISTOFIX"
                done

                if [[ "${NISTOFIX}x" == "x" ]]; then
                        echo "GEN001360 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001360 - Failed" | tee -a ${COMPLIANCE}
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
