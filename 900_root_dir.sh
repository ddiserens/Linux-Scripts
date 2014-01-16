#!/bin/bash
# "900_root_dir.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 900_root_dir.sh

C21FILE="/etc/passwd"
C21LINE=`awk -F: '($6 == "/") && ($1 == "root") {print $1}' /etc/passwd`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Create root home dir"
#Runs fix for STIG ID - GEN000900 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C21FILE}
echo "Fixing STIG ID - GEN000900"
mkdir /rootdir
chown root:root /rootdir
chmod 700 /rootdir
cp -r /root/.??* /rootdir/
usermod -d /rootdir root
${UTILDIR}/et -i ${C21FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
echo "Restoring"
DEL=`${UTILDIR}/rcsrevs ${C21FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C21FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C21FILE}
ci -u ${C21FILE}
rcs -o1.2:${DEL} ${C21FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN000900 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C21LINE}x" == "x"  ]; then
                        echo "GEN000900 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000900 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [ "${C21LINE}x" == "x" ]; then
                        echo "GEN000900 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000900 - Failed" | tee -a ${COMPLIANCE}
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
