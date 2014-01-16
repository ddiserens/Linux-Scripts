#!/bin/bash
# "1470_passwd_hash.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1470_passwd_hash.sh

C50FILE="/etc/passwd"
C50LINE=`awk -F':' '{if($2 != "x" && $2 != "*") print $1}' /etc/passwd | tr "\n" " "`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Move password hashes to /etc/shadow"
#Runs fix for STIG ID - GEN001470 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001470"
pwconv
}

#*******************************************************************************

restore_system ()
{
echo "Reverting changes is not recommended."
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000700 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C50LINE}x" == "x" ]]; then
                        echo "GEN001470 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001470 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C50LINE}x" == "x" ]]; then
                        echo "GEN001470 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001470 - Failed" | tee -a ${COMPLIANCE}
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
