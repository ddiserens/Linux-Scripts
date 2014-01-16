#!/bin/bash
################################################################################
# "100_system_release.sh" - Daniel Diserens <diserens@gdls.com>
# Version 1.0
################################################################################
#  DESCRIPTION: This script determines what version the operating systems is   #
#  running.			                                               #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.           #
################################################################################
# set -x

#Variables
. "/var/tmp/compliancecheck/lib/setup.lib"
#set_variables 
check_rtc 100_system_release.sh

BASE="4.9"
C2LINE=`cat /etc/redhat-release | awk -F" " '{ print $7 }'`

#*******************************************************************************

fix_system ()
{
#Runs fix for STIG ID - GEN000100 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000100" | tee -a ${FIX}
echo "You need to update to an approved Operating System" | tee -a ${FIX}
}

#*******************************************************************************

restore_system ()
{
echo "There is no way to revert back to a previous software release"
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000100 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [[ ${C2LINE} > ${BASE} ]]; then
        		echo "GEN000100 - Passed" | tee -a ${COMPLIANCE}
		else
        		echo "GEN000100 - Failed" | tee -a ${COMPLIANCE}
	                fix_system
        	                if [ $? != 0 ]; then
                	                echo "Fix Failed" | tee -a ${FIX}
                        	        restore_system
                        	fi
		fi
                ;;
	"Check")
		if [[ ${C2LINE} > ${BASE} ]]; then
                        echo "GEN000100 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000100 - Failed" | tee -a ${COMPLIANCE}
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
        *)
                echo "You have entered an invalid switch"
                exit 1
                ;;
esac
