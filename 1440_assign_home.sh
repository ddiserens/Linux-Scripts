#!/bin/bash
# "1440_assign_home.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1440_assign_home.sh

C49FILE="/etc/passwd"

#*******************************************************************************

#Function
fix_system ()
{
DESC="Creating home directories that do not exist"
#Runs fix for STIG ID - GEN001440 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001440"
for USER in ${HOMETOFIX}; do
	echo "/home/${USER}" >> ${FIX_DIR}/GEN1440_perm.${PDATE}.fix
	usermod -d "/home/${USER}" ${USER}
done
}

#*******************************************************************************

restore_system ()
{
echo "Delete ${FIX_DIR}/GEN1420_perm.${PDATE}.fix to revert changes"
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001440 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for CURLINE in `awk -F':' '{ print $1":"$3":"$4":"$6 }' ${C49FILE}`; do
			STR_ARRAY=(`echo $CURLINE | tr ":" "\n"`)
			
			CURUSER=${STR_ARRAY[0]}
			CURUID=${STR_ARRAY[1]}
			CURGID=${STR_ARRAY[2]}
			CURHOMEDIR=${STR_ARRAY[3]}

		        if [ "${CURHOMEDIR}" = "" ]; then
				HOMETOFIX="${CURUSER} ${HOMETOFIX}"
			fi
		done
					
		if [[ "${HOMETOFIX}x" == "x" ]]; then
                        echo "GEN001440 - Passed"
                else
                        echo "GEN001440 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
	"Check")
		#Checks STIG ID - GEN001440 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for CURLINE in `awk -F':' '{ print $1":"$3":"$4":"$6 }' ${C49FILE}`; do
                        STR_ARRAY=(`echo $CURLINE | tr ":" "\n"`)

                        CURUSER=${STR_ARRAY[0]}
                        CURUID=${STR_ARRAY[1]}
                        CURGID=${STR_ARRAY[2]}
                        CURHOMEDIR=${STR_ARRAY[3]}

                        if [ "${CURHOMEDIR}" = "" ]; then
                                HOMETOFIX="${CURUSER} ${HOMETOFIX}"
                        fi
                done
 
                if [[ "${HOMETOFIX}x" == "x" ]]; then
                        echo "GEN001440 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001440 - Failed" | tee -a ${COMPLIANCE}
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
