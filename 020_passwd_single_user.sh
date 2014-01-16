#/bin/bash
################################################################################
# "020_passwd_single_user.sh" - Daniel Diserens <diserens@gdls.com>            #
# Version 1.0								       #
################################################################################
#  DESCRIPTION: This script will modify inittab to require a password before   #
#  booting into single user mode.					       #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.	       #
################################################################################
# set -x

#Variables
. "/var/tmp/compliancecheck/lib/setup.lib"
#set_variables 
check_rtc 020_passwd_single_user.sh

C1FILE="/etc/inittab"
C1LINE=`awk '/\~\:S\:wait\:\/sbin\/sulogin/' ${C1FILE}`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Configure to require password when booting into single user mode"
#Runs fix for STIG ID - GEN000020 the Red Hat Enterprise Linux 5 STIG
if [ ! -d ${RCSPATH} ]; then
	mkdir -p ${RCSPATH}
fi
${UTILDIR}/et -o ${C1FILE} 2>${FIX}
echo "Fixing STIG ID - GEN000020" | tee -a ${FIX} 
echo "" | tee -a ${C1FILE} ${FIX}
echo "# Require the root pw when booting into single user mode" | tee -a ${C1FILE} ${FIX}
echo "~:S:wait:/sbin/sulogin" | tee -a ${C1FILE} ${FIX}
${UTILDIR}/et -i ${C1FILE} `echo $DESC` 2>${FIX}
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C1FILE} | sed -n 1p` 
if [[ $1 = "" ]]; then
	LATEST=`${UTILDIR}/rcsrevs ${C1FILE} | sed -n 2p`
	echo ${LATEST} | tee -a ${RESTORE} 
else
	LATEST=$1
	echo ${LATEST} | tee -a ${RESTORE}
fi
co -l -r${LATEST} ${C1FILE} 2>&1 >> ${RESTORE}
ci -u ${C1FILE} 2>&1 >> ${RESTORE}
rcs -o1.2:${DEL} ${C1FILE} 2>$1 >> ${RESTORE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
	"Complete") 
		#Checks STIG ID - GEN000020 the Red Hat Enterprise Linux 5 STIG for compliance
	        if [ "${C1LINE}x" != "x" ]; then
        	        echo "GEN000020 - Passed" | tee ${COMPLIANCE}
        	else
                	echo "GEN000020 - Failed" | tee ${COMPLIANCE}
			fix_system
			        if [ $? != 0 ]; then
                			echo "Fix Failed" | tee -a ${FIX}
                			restore_system
        			fi
		fi
		;;
	"Check")
                if [ "${C1LINE}x" != "x" ]; then
                        echo "GEN000020 - Passed" | tee ${COMPLIANCE}
                else
                        echo "GEN000020 - Failed" | tee ${COMPLIANCE}
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
	*)
		echo "You have entered an invalid switch"
		exit 1
		;;
esac
