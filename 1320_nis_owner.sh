#!/bin/bash
# "1320_nis_owner.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1320_nis_owner.sh

C31FILE="/var/yp"

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing owner on NIS files"
#Runs fix for STIG ID - GEN001320 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001320"
if [ ${NISFILESTOFIX} = "" ]; then
        if [ -d ${C31FILE} ]; then
               	for NISFILE in `find ${C31FILE} -type f`; do
			CUROWN=`stat -c $U ${NISFILE}`
	                # Print actual permissions to file for recovery
			echo "chown ${CUROWN} ${NISFILE}" >> ${FIX_DIR}/GEN1320_perm.${PDATE}.fix
		        chown root ${NISFILE}
		done
	fi
	
else
	for FILE in ${NISFILESTOFIX}; do
		# The log files cctual permissions
		CUROWN=`stat -c $U ${NISFILE}`
		# Print actual permissions to file for recovery
		echo "chown ${CUROWN} ${FILE}" >> ${FIX_DIR}/GEN1320_perm.${PDATE}.fix
		chmod root ${FILE}
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1320_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001320 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ -d ${C31FILE} ]; then
			for NISFILE in `find ${C31FILE} -type f`; do
				CUROWN=`stat -c %U ${NISFILE}`
				if [ "$CUROWN" != "root" -a "$CUROWN" != "sys" -a "$CUROWN" != "bin" ]; then
	                               	NISFILESTOFIX="$NISFILE $NISFILESTOFIX"
				fi
                       	done
		fi
                
                if [ "${NISFILESTOFIX}x" == "x" ]; then
       	                echo "GEN001320 - Passed" | tee -a ${COMPLIANCE}
               	else
                       	echo "GEN001320 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
       	                        if [ $? != 0 ]; then
               	                        echo "Fix Failed" | tee -a ${FIX}
                       	                restore_system
                               	fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN001320 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ -d ${C31FILE} ]; then
	                for NISFILE in `find ${C31FILE} -type f`; do
				CUROWN=`stat -c %U ${NISFILE}`
				if [ "$CUROWN" != "root" -a "$CUROWN" != "sys" -a "$CUROWN" != "bin" ]; then
                                        NISFILESTOFIX="$NISFILE $NISFILESTOFIX"
				fi
                        done
                fi
	
		if [ "${NISFILESTOFIX}x" == "x" ]; then
                	echo "GEN001320 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001320 - Failed" | tee -a ${COMPLIANCE}
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
