# "500_screen_saver.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 500_screen_saver.sh

C10FILE="/apps/gnome-screensaver/idle_activation_enabled"
C10LINE=`gconftool-2 --get /apps/gnome-screensaver/idle_activation_enabled`

#*******************************************************************************

fix_system ()
{
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.mandatory --type bool --set /apps/gnome-screensaver/idle_activation_enabled true
}

#*******************************************************************************

restore_system ()
{
DEL=`${UTILDIR}/rcsrevs ${C10FILE} | sed -n 1p`
if [[ $1 = "" ]]; then
        LATEST=`${UTILDIR}/rcsrevs ${C1FILE} | sed -n 2p`
        echo ${LATEST}
else
        LATEST=$1
        echo ${LATEST}
fi
co -l -r${LATEST} ${C10FILE}
ci -u ${C10FILE}
rcs -o1.2:${DEL} ${C10FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000500 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ "${C10LINE}" == "true" ]; then
		        echo "GEN000500 - Passed" | tee -a ${COMPLIANCE}
		else
		        echo "GEN000500 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000500 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ "${C10LINE}" == "true" ]; then
                        echo "GEN000500 - Passed" | tee -a ${COMPLIANCE}
                else
                        echo "GEN000500 - Failed" | tee -a ${COMPLIANCE}
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
