#!/bin/bash
# "1200_ww_files.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1200_ww_files.sh

C26FILE="/bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin"

#*******************************************************************************

#Function
fix_system ()
{
DESC="Change permissions on world-writable or group-writable files"
FILEPERMS=`stat -L --format='%04a' ${FILES}`
#Runs fix for STIG ID - GEN001200 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001200"
if [ ${WW_FILES} = "" ]; then
	for SYS_DIR in ${C26FILE}; do
		if [ -d "${SYS_DIR}" ]; then
			for FILES in `find ${SYS_DIR} ! -type l`; do
				if [ -e ${FILES} ]; then
			                echo "chmod ${FILEPERMS} ${FILESTOFIX}"
        	        		#chmod u-s,g-ws,o-wt ${FILESTOFIX}
		                	chmod g-w,o-w "${FILESTOFIX}"
				fi
			done
		fi
	done

else
	for FILETOFIX in ${WW_FILES}; do
		echo "chmod ${FILEPERMS} ${FILESTOFIX}"
		#chmod u-s,g-ws,o-wt ${FILESTOFIX}
		chmod g-w,o-w "${FILESTOFIX}"
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1200_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		for SYS_DIR in ${C26FILE}; do
			if [ -d "${SYS_DIR}" ]; then
				for FILES in `find ${SYS_DIR} ! -type l`; do
					if [ -e ${FILES} ]; then
						FILEPERMS=`stat -L --format='%04a' ${FILES}`
						
						FILESPECIAL=${FILEPERMS:0:1}
						FILEOWNER=${FILEPERMS:1:1}
						FILEGROUP=${FILEPERMS:2:1}
						FILEOTHER=${FILEPERMS:3:1}
						
						#if [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ]; then
						if [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEGROUP&2)) != "0" ] || [ $(($FILEOTHER&2)) != "0" ]; then
							WW_FILES="$FIND $WW_FILES"
						fi
					fi
				done
			fi
		done			
                #Checks STIG ID - GEN001200 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [[ "${WW_FILES}x" == "x" ]]; then
                        echo "GEN001200 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001200 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                for SYS_DIR in ${C26FILE}; do
                        if [ -d "${SYS_DIR}" ]; then
                                for FILES in `find ${SYS_DIR} ! -type l`; do
                                        if [ -e ${FILES} ]; then
                                                FILEPERMS=`stat -L --format='%04a' ${FILES}`

                                                FILESPECIAL=${FILEPERMS:0:1}
                                                FILEOWNER=${FILEPERMS:1:1}
                                                FILEGROUP=${FILEPERMS:2:1}
                                                FILEOTHER=${FILEPERMS:3:1}
                                                
                                                #if [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEOWNER&0)) != "0" ]; then
                                                if [ $(($FILEOWNER&0)) != "0" ] || [ $(($FILEGROUP&2)) != "0" ] || [ $(($FILEOTHER&2)) != "0" ]; then
                                                        WW_FILES="$FIND $WW_FILES"
                                                fi
                                        fi
                                done
                        fi
                done

                if [[ "${WW_FILES}x" == "x" ]]; then
                        echo "GEN001200 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001200 - Failed" | tee -a ${COMPLIANCE}
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
