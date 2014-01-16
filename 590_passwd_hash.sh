#!/bin/bash
# "590_passwd_hash.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 590_passwd_hash.sh

C15LINE=`authconfig --test | awk '/password hashing/ {print $5}'`

#*******************************************************************************


#*******************************************************************************

fix_system ()
{
DESC="Sets sha512 to be used for password hashing"
#Runs fix for STIG ID - GEN000590 the Red Hat Enterprise Linux 5 STIG
echo "Setting password hashing"
authconfig --passalgo=sha512 --update
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
authconfig --passalgo=md5 --update
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000590 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C15LINE}" == "sha512" ];then 
			echo "GEN000590 - Passed" | tee ${COMPLIANCE}
		else 
			echo "GEN000590 - Failed" | tee ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN000590 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C15LINE}" == "sha512" ];then 
			echo "GEN000590 - Passed" | tee ${COMPLIANCE}
		else 
			echo "GEN000590 - Failed" | tee ${COMPLIANCE}
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
