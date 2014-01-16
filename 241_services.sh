#!/bin/bash
################################################################################
# "241_services.sh" - Daniel Diserens <diserens@gdls.com>
# Version 1.0
################################################################################
#  DESCRIPTION: This script checks the service ntpd to ensure that it is       #
#  started.			                                               #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.           #
################################################################################
# set -x

#Variables
. "/var/tmp/compliancecheck/lib/setup.lib"
#set_variables 
check_rtc 241_services.sh

C3LINE=`chkconfig --list ntpd | awk -F"\t" '{ print $5" "$7 }'`
C3LINE2=`ls /var/run | grep ntpd`

#*******************************************************************************

#Function
fix_system ()
{
#Runs fix for STIG ID - GEN000241 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000241"
chkconfig ntpd on --level 35
service ntpd restart
}

#*******************************************************************************

restore_system ()
{
#If needed you can add to this function 
#service ntpd restart
echo ""
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000241 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C3LINE}" == "3:on 5:on" ] && [ "${C3LINE2}x" != "x" ]
		then
        		echo "GEN000241 - Passed" | tee -a ${COMPLIANCE}
		else
        		echo "GEN000241 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C3LINE}" == "3:on 5:on" ] && [ "${C3LINE2}x" != "x" ]
                then
                        echo "GEN000241 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000241 - Failed" | tee -a ${COMPLIANCE}
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
