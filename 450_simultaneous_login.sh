#!/bin/bash
# "450_simultaneous_login.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 450_simultaneous_login.sh

C8FILE="/etc/security/limits.conf"
C8LINE=`awk '/^* hard maxlogins 10/' ${C8FILE}`

#*******************************************************************************

fix_system ()
{
DESC="Change to only allow 10 simultaneous system logins"
#Runs fix for STIG ID - GEN000450 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C8FILE}
echo "Fixing STIG ID - GEN000450"
echo "* hard maxlogins 10" >> ${C8FILE}
${UTILDIR}/et -i ${C8FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C8FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C8FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C8FILE}
ci -u ${C8FILE}
rcs -o1.2:${DEL} ${C8FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000450 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C8LINE}x" != "x" ]; then
		        echo "GEN000450 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000450 - Failed" | tee -a ${COMPLIANCE}
                        fix_system 
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000450 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C8LINE}x" != "x" ]; then
                        echo "GEN000450 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000450 - Failed" | tee -a ${COMPLIANCE}
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
