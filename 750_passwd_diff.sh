#!/bin/bash
# "700_passwd_diff.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 750_passwd_diff.sh

C17FILE="/etc/pam.d/system-auth-local"
C17CHECK=`awk '/pam_cracklib.so try_first_pass/ && /difok=4/' ${C17FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Requiring a user to change at least four characters between his old and new password"
${UTILDIR}/et -o ${C17FILE}
echo "Fixing STIG ID - GEN000750"
C17LINE=`sed -i.bak -e '/pam_cracklib.so try_first_pass/ s/$/ difok=4/' ${C17FILE}`
${C17LINE}
${UTILDIR}/et -i ${C17FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C17FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C1FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C17FILE}
ci -u ${C17FILE}
rcs -o1.2:${DEL} ${C17FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000750 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C17CHECK}x" != "x" ]; then
                        echo "GEN000750 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000750 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C17CHECK}x" != "x" ]; then
                        echo "GEN000750 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000750 - Failed" | tee -a ${COMPLIANCE}
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
