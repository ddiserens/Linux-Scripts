#!/bin/bash
# "1240_program_group.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1240_program_group.sh

C28FILE="/etc /bin /usr/bin /usr/lbin /usr/ucb /sbin /usr/sbin"

#*******************************************************************************

#Function
system_group ()
{
CURGROUP=$1

for SYSGROUP in `awk -F ':' '{if($3 < 500) print $1}' /etc/group`; do
	if [ "$SYSGROUP" = "$CURGROUP" ]; then
		return 0
	fi
done

return 1
}

#*******************************************************************************

fix_system ()
{
DESC="Changing group on system files, programs, and directories"
#Runs fix for STIG ID - GEN001240 the Red Hat Enterprise Linux 5 STIG
if [ "${FILESTOFIX}" == "" ]; then
	for DIR in `find ${C28FILE} ! -type l`; do
		if [ -d "${DIR}" ]; then
	                for FILENAME in `find ${DIR} ! -type l`; do
        	                if [ -e ${FILENAME} ]; then
	        	        	CURGROUP=`stat -c %G $FILENAME`
        	        		echo "Fixing STIG ID - GEN001220"
                			echo "chgrp ${CURGROUP} ${FILENAME}" >> ${FIX_DIR}/GEN1240_perm.${PDATE}.fix
			                chgrp root ${FILENAME}
				fi
			done
		fi
        done

else
	for FILE in ${FILESTOFIX}; do
		CURGROUP=`stat -c %G $FILE`
		echo "Fixing STIG ID - GEN001240"
		echo "chgrp ${CURGROUP} ${FILE}" >> ${FIX_DIR}/GEN1240_perm.${PDATE}.fix
		chgrp root ${FILE}
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1240_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001240 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for CHKDIR in ${C28FILE}; do
			if [ -d "$CHKDIR" ]; then
				for FILENAME in `find $CHKDIR ! -type l`; do
					if [ -e ${FILENAME} ]; then
						CURGROUP=`stat -c %G $FILENAME`
						system_group $CURGROUP
						if [ $? -ne 0 ]; then
							FILESTOFIX="$CURGROUP $FILESTOFIX"
						fi
					fi
				done
			fi
		done
		 
                if [[ "${FILESTOFIX}x" == "x" ]]; then
                        echo "GEN001240 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001240 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001240 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for CHKDIR in ${C28FILE}; do
                        if [ -d "$CHKDIR" ]; then
                                for FILENAME in `find $CHKDIR ! -type l`; do
                                        if [ -e ${FILENAME} ]; then
                                                CURGROUP=`stat -c %G $FILENAME`
                                                system_group $CURGROUP
                                                if [ $? -ne 0 ]; then
                                                        FILESTOFIX="$CURGROUP $FILESTOFIX"
                                                fi
                                        fi
                                done
                        fi
                done
                      
                if [[ "${FILESTOFIX}x" == "x" ]]; then
                        echo "GEN001240 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001240 - Failed" | tee -a ${COMPLIANCE}
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
