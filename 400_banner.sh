#!/bin/bash
# "400_banner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc "400_banner.sh"

C7FILE="/etc/issue"
C7CHECK="/root/Desktop/stig/test/issue"
#C7CHECK="/media/dvd/issue"
C7LINE=`diff -q ${C7CHECK} ${C7FILE}`

#*******************************************************************************

fix_system ()
{
DESC="Modifying banner to comply with DOD Standards"
#Runs fix for STIG ID - GEN000400 the Red Hat Enterprise Linux 5 STIG
${UTILDIR}/et -o ${C7FILE}
echo "Fixing STIG ID - GEN000400"
cp ${C7CHECK} ${C7FILE}
${UTILDIR}/et -i ${C7FILE} `echo $DESC`
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C7FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C7FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C7FILE}
ci -u ${C7FILE}
rcs -o1.2:${DEL} ${C7FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000400 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C7LINE}x" == "x" ]; then
		        echo "GEN000400 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000400 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000400 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C7LINE}x" == "x" ]; then
                        echo "GEN000400 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000400 - Failed" | tee -a ${COMPLIANCE}
		fi
		;;
        "Fix")
		fix_system
	        if [ $? != 0 ]; then
			echo "Fix Failed" | tee -a ${COMPLIANCE}
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
