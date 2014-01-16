#!/bin/bash
# "1366_hosts_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1366_hosts_owner.sh

C35FILE="/etc/hosts"
C35LINE=`stat -c %U ${C35FILE}`

#*******************************************************************************

#Function
fix_system ()
{
#Saving Previous Settings
echo "chown ${C35LINE} /etc/hosts" > ${FIX_DIR}/GEN1366_perm.${PDATE}.fix

#Runs fix for STIG ID - GEN001366 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001366"
chown root /etc/hosts
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1366_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001366 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C35LINE}" == "root" ]]; then
                        echo "GEN001366 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001366 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C35LINE}" == "root" ]]; then
                        echo "GEN001366 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001366 - Failed" | tee -a ${COMPLIANCE}
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
