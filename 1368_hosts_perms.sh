#!/bin/bash
################################################################################
# "1368_hosts_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1368_hosts_perms.sh

C36FILE="/etc/hosts"
C36LINE=`stat -L --format='%04a' ${C36FILE}`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chmod ${C36LINE} ${C36FILE}" >> ${FIX_DIR}/GEN1368_perm.${PDATE}.fix
chmod 744 ${FIX_DIR}/GEN1368_perm.${PDATE}.fix


#Runs fix for STIG ID - GEN001368 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001368"
chmod 0644 /etc/hosts
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1368_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C36LINE}" == "0644" ]; then
                        echo "GEN001368 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001368 - Failed" | tee -a ${COMPLIANCE}
	                        if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001368 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C36LINE}" == "0644" ]; then
                        echo "GEN001368 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001368 - Failed" | tee -a ${COMPLIANCE}
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
