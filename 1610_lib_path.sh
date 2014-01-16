#!/bin/bash
# "1610_lib_path.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 1610_lib_path.sh

C54FILE="/etc/rc.d/"
C54LINE=`find ${C54FILE} -type f`

#*******************************************************************************

#Function
fix_system ()
{
DESC="Changing libraries to contain absolute paths"
#Runs fix for STIG ID - GEN001610 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN001610"
awk '/LD_PRELOAD=/ { if("${0}:x" != "x") { print $0 | "sed -i -e 's/LD_PRELOAD=:/LD_PRELOAD=/' ${INITFILE}" } }'
awk '/LD_PRELOAD=/ { if("${0}::x" != "x") { print $0 | "sed -i -e 's/LD_PRELOAD=::/LD_PRELOAD=/' ${INITFILE}" } }'
awk '/LD_PRELOAD=/ { print $0 | "sed -i -e 's/:$//'" }' ${INITFILE}

}

#*******************************************************************************

restore_system ()
{

}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
                #Checks STIG ID - GEN001610 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		for INITFILE in ${C54LINE}; do
			if [ -e ${INITFILE} ]; then
				LIBTOFIX="`awk '/LD_PRELOAD=/ { if("${0}:x" != "x") { print $0 } }' ${INITFILE}` ${LIBTOFIX}"
				LIBTOFIX1="`awk '/LD_PRELOAD=/ { if("${0}::x" != "x") { print $0 } }' ${INITFILE}` ${LIBTOFIX1}"
				LIBTOFIX2="`awk '/LD_PRELOAD=/ { print $0 | "sed -i -e 's/:$//'" }' ${INITFILE}
			fi

                if [[ "${LIBTOFIX}x" == "x" ]]; then
                        echo "GEN001610 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001610 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                if [[ "${LIBTOFIX}x" == "x" ]]; then
                        echo "GEN001610 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN001610 - Failed" | tee -a ${COMPLIANCE}
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
