#!/bin/bash
# "585_passwd_check.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 585_passwd_check.sh 

585FILE="/etc/shadow"
585LINE=`awk -F ':' '{if($2 ~ /^_/ && $2 ~ /^\\$/ && $2 ~ /!!/ && $2 ~ /\*/) print $1}' /etc/shadow`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Checking password hash of users"
#Runs fix for STIG ID - GEN000585 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${585FILE}
echo "Fixing STIG ID - GEN000585"
echo "Passwords for $USERS have a bad password hash"
${UTILDIR}/et -i ${585FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${585FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${585FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${585FILE}
ci -u ${585FILE}
rcs -o1.2:${DEL} ${585FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000585 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${585LINE}x" == "x" ]]; then
                        echo "GEN000585 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000585 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${585LINE}" == "x" ]]; then
                        echo "GEN000585 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000585 - Failed" | tee -a ${COMPLIANCE}
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
