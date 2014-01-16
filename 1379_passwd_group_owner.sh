#!/bin/bash
################################################################################
# "1379_passwd_group_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1379_passwd_group_owner.sh 

C41FILE="/etc/passwd"
C41LINE=`stat -c %G ${C41FILE}`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chgrp ${C41LINE} ${C41FILE}" >> ${FIX_DIR}/GEN1379_perm.${PDATE}.fix
chmod 744 ${FIX_DIR}/GEN1379_perm.${PDATE}.fix


#Runs fix for STIG ID - GEN001379 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001379"
chgrp root ${C41FILE}
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1379_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001379 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C41LINE}" == "root" -o "${C41LINE}" == "sys" -o "${C41LINE}" == "bin" ]; then
                        echo "GEN001379 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001379 - Failed" | tee -a ${COMPLIANCE}
	                        if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001379 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C41LINE}" == "root" -o "${C41LINE}" == "sys" -o "${C41LINE}" == "bin" ]; then
                        echo "GEN001379 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001379 - Failed" | tee -a ${COMPLIANCE}
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
