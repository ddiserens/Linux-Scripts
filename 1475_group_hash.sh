#!/bin/bash
# "1475_group_hash.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1475_group_hash.sh

C51FILE="/etc/group"
C51LINE=`awk -F':' '{if($2 != "x" && $2 != "*") print $1}' ${C51FILE} | tr "\n" " "`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Move password hashes to /etc/gshadow"
#Runs fix for STIG ID - GEN001475 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001475"
grpconv
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
                #Checks STIG ID - GEN001475 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C51LINE}x" == "x" ]]; then
                        echo "GEN001475 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001475 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C51LINE}x" == "x" ]]; then
                        echo "GEN001475 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001475 - Failed" | tee -a ${COMPLIANCE}
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
