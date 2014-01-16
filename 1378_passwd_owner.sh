#!/bin/bash
# "1378_passwd_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1378_passwd_owner.sh

C40FILE="/etc/passwd"
C40LINE=`stat -c %U ${C40FILE}`

#*******************************************************************************

#Function
fix_system ()
{
#Saving Previous Settings
echo "chown ${C40LINE} ${C40FILE}" > ${FIX_DIR}/GEN1378_perm.${PDATE}.fix

#Runs fix for STIG ID - GEN001378 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001378"
chown root ${C40FILE}
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1378_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001378 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C40LINE}" == "root" ]]; then
                        echo "GEN001378 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001378 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C40LINE}" == "root" ]]; then
                        echo "GEN001378 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001378 - Failed" | tee -a ${COMPLIANCE}
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
