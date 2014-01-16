#!/bin/bash
# "850_prevent_root.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 850_prevent_root.sh

C19FILE="/etc/pam.d/su"
C19CHECK=`awk '/^auth[[:space:]]*required[[:space:]]*pam_wheel.so use_uid/' ${C19FILE}`
C19FIX=`awk '/auth[[:space:]]*required[[:space:]]*pam_wheel.so use_uid/ && /^#/' ${C19FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Require user to be in the wheel group"
#Runs fix for STIG ID - GEN000850 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C19FILE}
echo "Fixing STIG ID - GEN000850"
if [ "${C19FIX}x" == "x" ]; then
	sed -i.bak '/'"^auth[[:space:]]*include"'/ i auth\t\trequired\tpam_wheel.so use_uid' ${C19FILE}
else
	sed -i.bak -e 's,#auth[[:space:]]*required[[:space:]]*pam_wheel.so,auth\t\trequired\tpam_wheel.so,' ${C19FILE}
fi
${UTILDIR}/et -i ${C19FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C19FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C19FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C19FILE}
ci -u ${C19FILE}
rcs -o1.2:${DEL} ${C19FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000850 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C19CHECK}x" != "x" ]; then
                        echo "GEN000850 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000850 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C19CHECK}x" != "x" ]; then
                        echo "GEN000850 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000850 - Failed" | tee -a ${COMPLIANCE}
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
