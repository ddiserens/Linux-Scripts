#!/bin/bash
# "1480_home_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1480_home_perms.sh

C52LINE=`awk -F':' '{ if($4 >= 500 && $1 != "nfsnobody" && $6 != "/" && "${6}x" != "x") print $6 }' /etc/passwd`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing permissions on home dir"
#Runs fix for STIG ID - GEN001480 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001480"
if [ "${DIRTOFIX}" = "" ]; then
	for FILE in ${C52LINE}; do
	        # The home dir actual permissions
	        FILEPERMS=`stat -L --format='%04a' ${DIRTOFIX}`

	        # Print actual permissions to file for recovery
	        echo "chmod ${FILEPERMS} ${FILE}" >> ${FIX_DIR}/GEN1480_perm.${PDATE}.fix
        	chmod 750 ${FILE}
	done
else
	for FILE in ${DIRTOFIX}; do
		# The home dir actual permissions
		FILEPERMS=`stat -L --format='%04a' ${DIRTOFIX}`

		# Print actual permissions to file for recovery
		echo "chmod ${FILEPERMS} ${FILE}" >> ${FIX_DIR}/GEN1480_perm.${PDATE}.fix
		chmod 750 ${FILE}
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1480_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001480 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for USERNAME in ${C52LINE}; do 
			if [ -d ${USERNAME} ]; then 
				DIRPERMS=`stat -L --format='%04a' ${USERNAME}`
					if [ ${DIRPERMS} != 750 ]; then 
						DIRTOFIX="${USERNAME} ${DIRTOFIX}"
					fi
			fi
		done

                if [ "${DIRTOFIX}x" == "x" ]; then
       	                echo "GEN001480 - Passed" | tee -a ${COMPLIANCE}
               	else
                       	echo "GEN001480 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
       	                        if [ $? != 0 ]; then
               	                        echo "Fix Failed" | tee -a ${FIX}
                       	                restore_system
                               	fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN001260 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for USERNAME in ${C52LINE}; do 
                        if [ -d ${USERNAME} ]; then 
                                DIRPERMS=`stat -L --format='%04a' ${USERNAME}`
                                        if [ ${DIRPERMS} != 750 ]; then 
                                                DIRTOFIX="${USERNAME} ${DIRTOFIX}" 
                                        fi
                        fi
                done

		if [ "${DIRTOFIX}x" == "x" ]; then
                	echo "GEN001480 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001480 - Failed" | tee -a ${COMPLIANCE}
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
