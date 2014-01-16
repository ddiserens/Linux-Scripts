#!/bin/bash
# "540_login_def.sh" - Daniel Diserens <diserens@gdls.com>
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

C11FILE="/etc/login.defs"
C11FILE1="/etc/default/useradd"
C11LINE=`awk '/^PASS_MIN_DAYS/' ${C11FILE} | awk -F' ' '{ print $2}'`
C11LINE1=`awk '/^PASS_MIN_DAYS/' ${C11FILE} | awk -F' ' '{ print $2}'`
C11CMD="sed -i.bak -e "s/^PASS_MIN_DAYS[[:space:]]*${C11LINE}/PASS_MIN_DAYS\\t1/" ${C11FILE}"

#*******************************************************************************

#*******************************************************************************

fix_system ()
{
DESC="Modifying banner to comply with DOD Standards"
#Runs fix for STIG ID - GEN000540 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C11FILE}
echo "Fixing STIG ID - GEN000540"
eval ${C11CMD}
${UTILDIR}/et -i ${C11FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C11FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C11FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C11FILE}
ci -u ${C11FILE}
rcs -o1.2:${DEL} ${C11FILE}
}

#*******************************************************************************

#Checks for exception
check_rtc 540_login_def.sh

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000540 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C11LINE}" == "1" ]; then
		        echo "GEN000540 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000540 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN000540 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C11LINE}" == "1" ]; then
		        echo "GEN000540 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000540 - Failed" | tee -a ${COMPLIANCE}
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
