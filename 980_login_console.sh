#!/bin/bash
# "980_login_console.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 980_login_console.sh

C23FILE="/etc/securetty"
C23LINE=`cat /etc/securetty` 

#*******************************************************************************

#Function
fix_system ()
{
DESC="Allow only root to login through console"
#Runs fix for STIG ID - GEN000980 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C23FILE}
echo "Fixing STIG ID - GEN000980"
echo console > ${C23FILE}
${UTILDIR}/et -i ${C23FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C23FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C23FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C23FILE}
ci -u ${C23FILE}
rcs -o1.2:${DEL} ${C23FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000980 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C23LINE}" == "console"  ]; then
                        echo "GEN000980 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000980 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C23LINE}" == "console" ]; then
                        echo "GEN000980 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000980 - Failed" | tee -a ${COMPLIANCE}
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
