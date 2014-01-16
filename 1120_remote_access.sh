#!/bin/bash
# "1120_remote_access.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1120_remote_access.sh

C25FILE="/etc/ssh/sshd_config"
C25LINE=`awk '/^PermitRootLogin/ { print $2 }' ${C25FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Remote root login is not allowed."
#Runs fix for STIG ID - GEN001120 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C25FILE}
echo "Fixing STIG ID - GEN001120"
sed -i.bak 's/^.PermitRootLogin[[:space:]].*/PermitRootLogin no/g' ${C25FILE}
${UTILDIR}/et -i ${C25FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C25FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C25FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C25FILE}
ci -u ${C25FILE}
rcs -o1.2:${DEL} ${C25FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001120 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C25LINE}" == "no" ]]; then
                        echo "GEN001120 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001120 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C25LINE}" == "no" ]]; then
                        echo "GEN001120 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001120 - Failed" | tee -a ${COMPLIANCE}
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
