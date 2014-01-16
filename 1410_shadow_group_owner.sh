#!/bin/bash
################################################################################
# "1410_shadow_group_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1410_shadow_group_owner.sh 

C47FILE="/etc/shadow"
C47LINE=`stat -c %G ${C47FILE}`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chgrp ${C47LINE} ${C47FILE}" >> ${FIX_DIR}/GEN1410_perm.${PDATE}.fix
chmod 744 ${FIX_DIR}/GEN1410_perm.${PDATE}.fix


#Runs fix for STIG ID - GEN001410 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001410"
chgrp root ${C47FILE}
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1410_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001410 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C47LINE}" == "root" -o "${C47LINE}" == "sys" -o "${C47LINE}" == "bin" ]; then
                        echo "GEN001410 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001410 - Failed" | tee -a ${COMPLIANCE}
	                        if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001410 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C47LINE}" == "root" -o "${C47LINE}" == "sys" -o "${C47LINE}" == "bin" ]; then
                        echo "GEN001410 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001410 - Failed" | tee -a ${COMPLIANCE}
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
