#!/bin/bash
# "880_account_uid.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 880_account_uid.sh

C20FILE2="/etc/shadow"
C20FILE="/etc/passwd"
C20LINE=`awk -F: '($3 == "0") && ($1 != "root") { print $1 }' ${C20FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Lock non-root user accounts with uid of 0"
#Runs fix for STIG ID - GEN000880 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C20FILE2}
echo "Fixing STIG ID - GEN000880"
for USERS in ${C20LINE}; do
	echo "Locking ${USERS}"
	passwd -l ${USERS}
done
${UTILDIR}/et -i ${C20FILE2} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C20FILE2} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C20FILE2} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C20FILE2}
ci -u ${C20FILE2}
rcs -o1.2:${DEL} ${C20FILE2}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000880 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C20LINE}x" == "x" ]]; then
                        echo "GEN000880 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000880 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C20LINE}x" == "x" ]]; then
                        echo "GEN000880 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000880 - Failed" | tee -a ${COMPLIANCE}
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
