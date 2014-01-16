#!/bin/bash
################################################################################
# "1372_nsswitch_group_own.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1372_nsswitch_group_own.sh

C38FILE="/etc/nsswitch.conf"
C38LINE=`stat -c %G ${C38FILE}`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chgrp ${C38LINE} ${C38FILE}" >> ${FIX_DIR}/GEN1372_perm.${PDATE}.fix
chmod 744 ${FIX_DIR}/GEN1372_perm.${PDATE}.fix


#Runs fix for STIG ID - GEN001372 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001372"
chgrp root ${C38FILE}
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1372_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001372 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C38LINE}" == "root" -o "${C38LINE}" == "sys" -o "${C38LINE}" == "bin" ]; then
                        echo "GEN001372 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001372 - Failed" | tee -a ${COMPLIANCE}
	                        if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001372 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C38LINE}" == "root" -o "${C38LINE}" == "sys" -o "${C38LINE}" == "bin" ]; then
                        echo "GEN001372 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001372 - Failed" | tee -a ${COMPLIANCE}
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
