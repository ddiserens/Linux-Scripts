#!/bin/bash
################################################################################
# "1392_group_group_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1392_group_group_owner.sh 

C44FILE="/etc/group"
C44LINE=`stat -c %G ${C44FILE}`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chgrp ${C44LINE} ${C44FILE}" >> ${FIX_DIR}/GEN1392_perm.${PDATE}.fix
chmod 744 ${FIX_DIR}/GEN1392_perm.${PDATE}.fix


#Runs fix for STIG ID - GEN001392 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001392"
chgrp root ${C44FILE}
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1392_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001392 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C44LINE}" == "root" -o "${C44LINE}" == "sys" -o "${C44LINE}" == "bin" ]; then
                        echo "GEN001392 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001392 - Failed" | tee -a ${COMPLIANCE}
	                        if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001392 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C44LINE}" == "root" -o "${C44LINE}" == "sys" -o "${C44LINE}" == "bin" ]; then
                        echo "GEN001392 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001392 - Failed" | tee -a ${COMPLIANCE}
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
