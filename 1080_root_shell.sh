#!/bin/bash
# "1080_root_shell.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1080_root_shell.sh 

C24FILE="/etc/passwd"
C24LINE=`awk -F":" '/^root/ { print $7 }' /etc/passwd`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Modifying roots shell to meet requirements of GEN0001080"
#Runs fix for STIG ID - GEN001080 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C24FILE}
echo "Fixing STIG ID - GEN001080"
chsh -s /bin/bash root
${UTILDIR}/et -i ${C24FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C24FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C24FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C24FILE}
ci -u ${C24FILE}
rcs -o1.2:${DEL} ${C24FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001080 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${C24LINE}" == "/bin/bash" ]]; then
                        echo "GEN001080 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001080 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${C24LINE}" == "/bin/bash" ]]; then
                        echo "GEN001080 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001080 - Failed" | tee -a ${COMPLIANCE}
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
