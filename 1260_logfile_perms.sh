#!/bin/bash
# "1260_logfile_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1260_logfile_perms.sh

C28LINE=`find /var/log/ -type f | grep -v wtmp`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing permissions on log files"
#Runs fix for STIG ID - GEN001260 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001260"
for FILE in ${LOGFILESTOFIX}; do
	# The log files cctual permissions
	FILEPERMS=`stat -L --format='%04a' ${LOGFILESTOFIX}`
	# Print actual permissions to file for recovery
	echo "chmod ${FILEPERMS} ${FILE}" >> ${FIX_DIR}/GEN1260_perm.${PDATE}.fix
	chmod u-xs,g-wxs,o-rwxt ${FILE}
done
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1260_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001260 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for LOGFILE in ${C28LINE}; do
		        # The log files cctual permissions
		        FILEPERMS=`stat -L --format='%04a' ${LOGFILE}`

		        # Break the actual file octal permissions up per entity
		        FILESPECIAL=${FILEPERMS:0:1}
		        FILEOWNER=${FILEPERMS:1:1}
		        FILEGROUP=${FILEPERMS:2:1}
		        FILEOTHER=${FILEPERMS:3:1}

		        # Run check for unwanted mask(7137)
	                if [ $(($FILESPECIAL&7)) != 0 ] || [ $(($FILEOWNER&1)) != 0 ] || [ $(($FILEGROUP&3)) != 0 ] || [ $(($FILEOTHER&7)) != 0 ]; then
                                LOGFILESTOFIX="$LOGFILE $LOGFILESTOFIX"
                        fi
                done

                if [ "${LOGFILESTOFIX}x" == "x" ]; then
       	                echo "GEN001260 - Passed" | tee -a ${COMPLIANCE}
               	else
                       	echo "GEN001260 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
       	                        if [ $? != 0 ]; then
               	                        echo "Fix Failed" | tee -a ${FIX}
                       	                restore_system
                               	fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN001260 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for LOGFILE in ${C28LINE}; do
                        # The log files actual permissions
                        FILEPERMS=`stat -L --format='%04a' ${LOGFILE}`

                        # Break the actual file octal permissions up per entity
                        FILESPECIAL=${FILEPERMS:0:1}
                        FILEOWNER=${FILEPERMS:1:1}
                        FILEGROUP=${FILEPERMS:2:1}
                        FILEOTHER=${FILEPERMS:3:1}

                        # Run check for unwanted mask(7137)
                        if [ $(($FILESPECIAL&7)) != 0 ] || [ $(($FILEOWNER&1)) != 0 ] || [ $(($FILEGROUP&3)) != 0 ] || [ $(($FILEOTHER&7)) != 0 ]; then
				LOGFILESTOFIX="$LOGFILE $LOGFILESTOFIX"
			fi
		done	
		
		if [ "${LOGFILESTOFIX}x" == "x" ]; then
                	echo "GEN001260 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001260 - Failed" | tee -a ${COMPLIANCE}
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
