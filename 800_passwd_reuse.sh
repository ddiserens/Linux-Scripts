#!/bin/bash
# "800_passwd_reuse.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 800_passwd_reuse.sh

C18FILE="/etc/pam.d/system-auth-local"
C18CHECK=`awk '/password[[:space:]]*sufficient[[:space:]]*pam_unix.so/ && /remember=5/' ${C18FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Requiring a user to change at least four characters between his old and new password"
${UTILDIR}/et -o ${C18FILE}
echo "Fixing STIG ID - GEN000800"
C18LINE=`sed -i '/password[[:space:]]*sufficient[[:space:]]*pam_unix.so/ {/remember=5/! s/.*/& remember=5/}' ${C18FILE}`
${C18LINE}
${UTILDIR}/et -i ${C18FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C18FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C1FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C18FILE}
ci -u ${C18FILE}
rcs -o1.2:${DEL} ${C18FILE}
}

#*******************************************************************************

if [ -a "/etc/security/opasswd" ]; then
	touch /etc/security/opasswd
	chown root:root /etc/security/opasswd
	chmod 0600 /etc/security/opasswd
fi
	
#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000800 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C18CHECK}x" != "x" ]; then
                        echo "GEN000800 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000800 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000800 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C18CHECK}x" != "x" ]; then
                        echo "GEN000800 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000800 - Failed" | tee -a ${COMPLIANCE}
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
