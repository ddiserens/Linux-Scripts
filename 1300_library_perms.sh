#!/bin/bash
# "1300_library_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1300_library_perms.sh

C30FILE="/usr/lib /usr/lib64 /lib /lib64"
C30LINE=`find /var/log/ -type f | grep -v wtmp`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing permissions on log files"
#Runs fix for STIG ID - GEN001300 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001300"
if [ ${LIBFILESTOFIX} = "" ]; then
	for LIBDIR in ${C30FILE}; do
        	if [ -d $LIBDIR ]; then
                	for LIBFILE in `find $LIBDIR -type f -perm /7022 \( -name *.so* -o -name *.a* \)`; do
				FILEPERMS=`stat -L --format='%04a' ${LIBFILESTOFIX}`
		                # Print actual permissions to file for recovery
                		echo "chmod ${FILEPERMS} ${FILE}" >> ${FIX_DIR}/GEN1300_perm.${PDATE}.fix
		                chmod o-s,g-ws,o-wt ${FILE}
			done
		fi
	done
else
	for FILE in ${LIBFILESTOFIX}; do
		# The log files cctual permissions
		FILEPERMS=`stat -L --format='%04a' ${LIBFILESTOFIX}`
		# Print actual permissions to file for recovery
		echo "chmod ${FILEPERMS} ${FILE}" >> ${FIX_DIR}/GEN1300_perm.${PDATE}.fix
		chmod o-s,g-ws,o-wt ${FILE}
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1300_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001300 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for LIBDIR in ${C30FILE}; do
			if [ -d $LIBDIR ]; then
				for LIBFILE in `find $LIBDIR -type f -perm /7022 \( -name *.so* -o -name *.a* \)`; do
                                	LIBFILESTOFIX="$LIBFILE $LIBFILESTOFIX"
                        	done
			fi
                done

                if [ "${LIBFILESTOFIX}x" == "x" ]; then
       	                echo "GEN001300 - Passed" | tee -a ${COMPLIANCE}
               	else
                       	echo "GEN001300 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
       	                        if [ $? != 0 ]; then
               	                        echo "Fix Failed" | tee -a ${FIX}
                       	                restore_system
                               	fi
                fi
                ;;
        "Check")
		#Checks STIG ID - GEN001300 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for LIBDIR in ${C30FILE}; do
                        if [ -d $LIBDIR ]; then
                                for LIBFILE in `find $LIBDIR -type f -perm /7022 \( -name *.so* -o -name *.a* \)`; do
                                        LIBFILESTOFIX="$LIBFILE $LIBFILESTOFIX"
                                done
                        fi
                done
	
	
		if [ "${LIBFILESTOFIX}x" == "x" ]; then
                	echo "GEN001300 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001300 - Failed" | tee -a ${COMPLIANCE}
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
