#!/bin/bash
# "920_rootdir_perm.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 920_rootdir_perm.sh

C22FILE="/etc/passwd"
C22LINE=`stat /rootdir | sed -n '/^Access: (/{s/Access: (\([0-9]\+\).*$/\1/;p}'`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Create root home dir"
#Runs fix for STIG ID - GEN000920 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000920"
echo "chmod ${C22LINE} /rootdir" >> ${FIX_DIR}/GEN920_perm.${PDATE}.fix
chmod 700 /rootdir
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN920_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000920 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C22LINE}" == "0700"  ]; then
                        echo "GEN000920 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000920 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C22LINE}" == "0700" ]; then
                        echo "GEN000920 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000920 - Failed" | tee -a ${COMPLIANCE}
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
