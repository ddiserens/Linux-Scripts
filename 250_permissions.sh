#!/bin/bash
################################################################################
# "250_permissions.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 250_permissions.sh

C4LINE=`ls -la /etc/ntp.conf | awk '{ print $3 }'`
C5LINE=`stat /etc/ntp.conf | sed -n '/^Access: (/{s/Access: (\([0-9]\+\).*$/\1/;p}'`

#*******************************************************************************

fix_system ()
{
#Saving Previous Settings
echo "chown ${C4LINE} /etc/ntp.conf" > ${FIX_DIR}/perm.${PDATE}.log
echo "chmod ${C5LINE} /etc/ntp.conf" >> ${FIX_DIR}/perm.${PDATE}.log
chmod 744 ${FIX_DIR}/perm.${PDATE}.fix

#Runs fix for STIG ID - GEN000250 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000250"
chown root /etc/ntp.conf

#Runs fix for STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000252"
chmod 0640 /etc/ntp.conf
}

#*******************************************************************************

restore_system ()
{
echo "Reverting changes"
${FIX_DIR}/perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000250 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C4LINE}" == "root" ]; then
		        echo "GEN000250 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000250 - Failed" | tee -a ${COMPLIANCE}
                        250_fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi

		#Checks STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C5LINE}" == "0640" ]; then
		        echo "GEN000252 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000252 - Failed" | tee -a ${COMPLIANCE}
                        252_fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000250 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C4LINE}" == "root" ]; then
                        echo "GEN000250 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000250 - Failed" | tee -a ${COMPLIANCE}
		fi

                #Checks STIG ID - GEN000252 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C5LINE}" == "0640" ]; then
                        echo "GEN000252 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000252 - Failed" | tee -a ${COMPLIANCE}
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
