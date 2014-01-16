#!/bin/bash
# "700_passwd_aging.sh" - Daniel Diserens <diserens@gdls.com>
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

C16LINE=`cat /etc/passwd | grep /home | cut -d":" -f1`

#*******************************************************************************

#Function
fix_system ()
{
for USER in ${NOTSET}; do
	passwd -x 60 ${USER}
done
}

#*******************************************************************************

restore_system ()
{
echo "If aging needs to be changed run passwd -x [age] [username]"
}

#*******************************************************************************

#Checks for exception
check_rtc 700_passwd_aging.sh

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000700 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for USERNAME in ${C16LINE}; do
		C16CMD=`chage -l ${USERNAME} | awk '/Maximum number of days between password change/' | awk -F': ' '{ print $2 }'`
		      	if [ $C16CMD == "60" ]; then
                        	echo "User ${USERNAME} password aging set correctly"
 >> ${COMPLIANCE}
                        else
                                NOTSET="${USERNAME} ${NOTSET}"
                        fi
                done
		if [ "${NOTSET}x" == "x" ]; then
                       	echo "GEN000700 - Passed" | tee -a ${COMPLIANCE}
                else
       	        	echo "GEN000700 - Failed" | tee -a ${COMPLIANCE}
               	        fix_system
                       		if [ $? != 0 ]; then
                               		echo "Fix Failed" | tee -a ${FIX}
                                       	restore_system
                                fi
		fi
		;;
        "Check")
		for USERNAME in ${C16LINE}; do
		C16CMD=`chage -l ${USERNAME} | awk '/Maximum number of days between password change/' | awk -F': ' '{ print $2 }'`
			if [ "${C16CMD}" == "60" ]; then
				echo "User ${USERNAME} password aging set correctly" >> ${COMPLIANCE}
			else
				NOTSET="${USERNAME} ${NOTSET}"
			fi
		done
                if [ "${NOTSET}x" == "x" ]; then
                        echo "GEN000700 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000700 - Failed" | tee -a ${COMPLIANCE}
                fi
                ;;
        "Fix")
		NOTSET=${C16LINE}
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
