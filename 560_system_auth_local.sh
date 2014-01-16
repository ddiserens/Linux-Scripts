#!/bin/bash
# "560_system_auth_local.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 560_system_auth_local.sh

IFS=$','
C12FILE="/etc/pam.d/system-auth-local"
C12CHECK=`awk '/nullok/' /etc/pam.d/system-auth-local`
C12FIX=`sed -i.backup -e 's/nullok //' /etc/pam.d/system-auth-local`

#*******************************************************************************

check_system ()
{
#Checks STIG ID - GEN000560 the Red Hat Enterprise Linux 5 STIG to see if its compliant
if [ "${C12CHECK}x" == "x" ]; then
        echo "GEN000560 - Passed" | tee -a ${COMPLIANCE}
else
        echo "GEN000560 - Failed" | tee -a ${COMPLIANCE}
fi
}

#*******************************************************************************

fix_system ()
{
#Runs fix for STIG ID - GEN000560 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000560"
${C12FIX}
}

#*******************************************************************************

restore_system ()
{
cp ${C12FILE}.backup ${C12FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000560 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C12CHECK}x" == "x" ]; then
		        echo "GEN000560 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000560 - Failed" | tee -a ${COMPLIANCE}
			fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000560 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C12CHECK}x" == "x" ]; then
                        echo "GEN000560 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000560 - Failed" | tee -a ${COMPLIANCE}
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
