#!/bin/bash
# "1220_program_perms.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1220_program_perms.sh

C27FILE="/etc /bin /usr/bin /usr/lbin /usr/ucb /sbin /usr/sbin"

#*******************************************************************************

#Function
system_user ()
{
CURUSER=$1

for SYSUSER in `awk -F ':' '{if($3 < 500) print $1}' /etc/passwd`; do
	if [ "$SYSUSER" = "$CURUSER" ]; then
		return 0
	fi
done

return 1
}

#*******************************************************************************

fix_system ()
{
DESC="Changing permissions on system files, programs, and directories"
#Runs fix for STIG ID - GEN001220 the Red Hat Enterprise Linux 5 STIG
if [ "${FILESTOFIX}" == "" ]; then
	for DIR in `find ${C27FILE} ! -type l`; do
		if [ -d "${DIR}" ]; then
	                for FILENAME in `find ${DIR} ! -type l`; do
        	                if [ -e ${FILENAME} ]; then
	        	        	CUROWN=`stat -c %U $FILENAME`
        	        		echo "Fixing STIG ID - GEN001220"
                			echo "chmod ${CUROWN} ${FILENAME}" >> ${FIX_DIR}/GEN1220_perm.${PDATE}.fix
			                chmod root ${FILENAME}
				fi
			done
		fi
        done

else
	for FILE in ${FILESTOFIX}; do
		CUROWN=`stat -c %U $FILE`
		echo "Fixing STIG ID - GEN001220"
		echo "chmod ${CUROWN} ${FILE}" >> ${FIX_DIR}/GEN1220_perm.${PDATE}.fix
		chmod root ${FILE}
	done
fi
}

#*******************************************************************************

restore_system ()
{
echo "Reverting Changes"
${FIX_DIR}/GEN1220_perm.${PDATE}.fix
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001220 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for CHKDIR in ${C27FILE}; do
			if [ -d "$CHKDIR" ]; then
				for FILENAME in `find $CHKDIR ! -type l`; do
					if [ -e ${FILENAME} ]; then
						CUROWN=`stat -c %U $FILENAME`
						system_user $CUROWN
						if [ $? -ne 0 ]; then
							FILESTOFIX="$CUROWN $FILESTOFIX"
						fi
					fi
				done
			fi
		done
		 
                if [[ "${FILESTOFIX}x" == "x" ]]; then
                        echo "GEN001220 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001220 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN001220 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                for CHKDIR in ${C27FILE}; do
                        if [ -d "$CHKDIR" ]; then
                                for FILENAME in `find $CHKDIR ! -type l`; do
                                        if [ -e ${FILENAME} ]; then
                                                CUROWN=`stat -c %U $FILENAME`
                                                system_user $CUROWN
                                                if [ $? -ne 0 ]; then
                                                        FILESTOFIX="$CUROWN $FILESTOFIX"
                                                fi
                                        fi
                                done
                        fi
                done
                      
                if [[ "${FILESTOFIX}x" == "x" ]]; then
                        echo "GEN001220 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001220 - Failed" | tee -a ${COMPLIANCE}
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
