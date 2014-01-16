#!/bin/bash
# "380_GID_passwd.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 380_GID_passwd.sh

TDATE=`date +%Y%m%d`
#C6FILE="/etc/default/useradd"
#C6LINE=`awk '/GROUP/' ${C6FILE} | awk -F= '{ print $2}'`
C6FILE="/etc/group"
C6FILE1="/etc/gshadow"
C6LINE=`cat /etc/passwd | awk -F: '{print $4}' | sort -g`
C6LINE2=`cat /etc/group | awk -F: '{print $3}' | sort -g`

#*******************************************************************************

fix_system ()
{
#Runs fix for STIG ID - GEN000380 the Red Hat Enterprise Linux 5 STIG
DESC="Changing GID of the groups in passwd to a default GID"
${UTILDIR}/et -o ${C6FILE}
if [ -f ${C6FILE1} ]; then
	${UTILDIR}/et -o ${C6FILE1}
fi
echo "Fixing STIG ID - GEN000380"
groupadd -g ${NOTINFILE} added${TDATE}
#FIXC6=`${C6CHECK} | awk -F"=" { print $2 }`
#sed -e 's/${FIXC6}/100/ig' ${C6FILE}
${UTILDIR}/et -i ${C6FILE} `echo $DESC`
if [ -f ${C6FILE1} ]; then
	${UTILDIR}/et -i ${C6FILE1} `echo $DESC`
fi
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C7FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C6FILE} | sed -n 2p`
	LATEST1=`${UTILDIR}/rcsrevs ${C6FILE1} | sed -n 2p`
        echo ${LATEST}
	echo ${LATEST1}
else
        LATEST=$1
	LATEST1=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C6FILE}
co -l -r${LATEST} ${C6FILE1}
ci -u ${C6FILE}
ci -u ${C6FILE1}
rcs -o1.2:${DEL} ${C7FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000380 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for W in $C6LINE; do
	        	if [ "`echo "$C6LINE2" | grep -w "$W"`x" == "x" ]; then
                		NOTINFILE="$NOTINFILE $W"
		        fi
		done
		if [ "${NOTINFILE}x" == "x" ]; then
		        echo "GEN000380 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000380 - Failed" | tee -a ${COMPLIANCE}
		        echo "There isn't a group on this system with a GID of ${NOTINFILE}"
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000380 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for W in $C6LINE; do
                        if [ "`echo "$C6LINE2" | grep -w "$W"`x" == "x" ]; then
                                NOTINFILE="$NOTINFILE $W"
                        fi
                done
                if [ "${NOTINFILE}x" == "x" ]; then
                        echo "GEN000380 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000380 - Failed" | tee -a ${COMPLIANCE}
                        echo "There isn't a group on this system with a GID of ${NOTINFILE}"
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
