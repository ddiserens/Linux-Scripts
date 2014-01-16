#!/bin/bash
################################################################################
# "252_permissions.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 252_permissions.sh

C5LINE=`stat /etc/ntp.conf | sed -n '/^Access: (/{s/Access: (\([0-9]\+\).*$/\1/;p}'`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chmod ${C5LINE} /etc/ntp.conf" >> ${FIX_DIR}/perm.${PDATE}.log
chmod 744 ${FIX_DIR}/perm.${PDATE}.fix


#Runs fix for STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000252"
chmod 0640 /etc/ntp.conf
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C5LINE}" == "0640" ]; then
                        echo "GEN000252 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000252 - Failed" | tee -a ${COMPLIANCE}
                        252_fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C5LINE}" == "0640" ]; then
                        echo "GEN000252 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000252 - Failed" | tee -a ${COMPLIANCE}
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
