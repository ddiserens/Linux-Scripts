#!/bin/bash
# "1362_resolv_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1362_resolv_owner.sh

C33FILE="/etc/resolv.conf"
C33LINE=`ls -la ${C33FILE} | awk '{ print $3 }'`

#*******************************************************************************

#Function
fix_system ()
{
#Saving Previous Settings
echo "chown ${C33LINE} /etc/resolv.conf" > ${FIX_DIR}/GEN1362_perm.${PDATE}.fix

#Runs fix for STIG ID - GEN001362 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001362"
chown root /etc/resolv.conf
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1362_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001362 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C33LINE}" == "root" ]]; then
                        echo "GEN001362 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001362 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C33LINE}" == "root" ]]; then
                        echo "GEN001362 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001362 - Failed" | tee -a ${COMPLIANCE}
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
