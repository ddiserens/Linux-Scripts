# "460_system_auth.sh" - Daniel Diserens <diserens@gdls.com>
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
check_rtc 460_system_auth.sh

IFS=$','
C9DIR="/etc/pam.d"
C9FILE="${C9DIR}/system-auth"
C9FILE2="${C9DIR}/system-auth-local"
C9FILE3="${C9DIR}/system-auth-ac"
C9LINE='/auth[[:space:]]required[[:space:]]pam_access.so/,/auth[[:space:]]required[[:space:]]pam_tally2.so deny=3/,/auth[[:space:]]include[[:space:]]system-auth-ac/,/account[[:space:]]required[[:space:]]pam_tally2.so/,/account[[:space:]]include[[:space:]]system-auth-ac/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]minlen=14/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]ucredit=-1/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]lcredit=-1/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]dcredit=-1/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]ocredit=-1/,/password[[:space:]]required[[:space:]]pam_cracklib.so[[:space:]]maxrepeat=3/,/password[[:space:]]include[[:space:]]system-auth-ac/,/session[[:space:]]include[[:space:]]system-auth-ac/'
C9COMMAND=`ls -l ${C9FILE} | awk -F' ' '{print $11}'`

#*******************************************************************************

fix_system ()
{
#Runs fix for STIG ID - GEN000460 the Red Hat Enterprise Linux 5 STIG
echo "Fixing STIG ID - GEN000460"
for W in ${NOTINFILE}; do
	if [ `echo $W | awk -F'\' '{ print $1 }'` == "auth" ];then
		C9CMD=`sed -i.bak -e '/auth[[:space:]]*required[[:space:]]*pam_deny.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2}`
		${C9CMD}
	elif [ `echo $W | awk -F'\' '{ print $1 }'` == "account" ];then
        	C9CMD1=`sed -i.bak -e '/account[[:space:]]*required[[:space:]]*pam_permit.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2}`
		${C9CMD1}
	elif [ `echo $W | awk -F'\' '{ print $1 }'` == "password" ];then
		C9CMD2=`sed -i.bak -e '/password[[:space:]]*required[[:space:]]*pam_deny.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2}`
		${C9CMD2}
	else
		echo -e "$W" >> ${C9FILE2}
	fi
done
unset IFS

if [ `ls -l ${C9FILE} |awk -F' ' '{print $11}'` != /etc/pam.d/system-auth-ac ]; then
	cp ${C9FILE3} ${C9FILE2}.tmp
else
	unlink ${C9FILE}
	cp ${C9FILE3} ${C9FILE2}.tmp
fi
ln -s ${C9FILE2} ${C9FILE}
}

#*******************************************************************************

restore_system ()
{
unlink ${C9FILE}
cp ${C9FILE2}.tmp ${C9FILE3}
ln -s ${C9FILE3} ${C9FILE}
}

#*******************************************************************************

#Checks RUN_TYPE
case "${RUN_TYPE}" in
        "Complete")
		#Checks STIG ID - GEN000460 the Red Hat Enterprise Linux 5 STIG to see if its compliant
		if [ ! -f ${C9FILE2} ]; then
			cp ${C9FILE3} ${C9FILE2}
		fi
		for W in ${C9LINE}; do
			C9CMD=`gawk "$W" ${C9FILE2}`
			if [ "${C9CMD}x" == "x" ]; then
				W=`echo $W | sed 's/\[\[\:space\:\]\]/\\\t/'g | sed 's/\///'g`  
				if [ "`echo ${NOTINFILE}`x" == x ];then
					NOTINFILE="$W"
				else
					NOTINFILE="$NOTINFILE,$W"
				fi
			fi
		done
		if [ "${NOTINFILE}x" == "x" ] && [ "${C9COMMAND}" == "/etc/pam.d/system-auth-local" ]; then
		        echo "GEN000460 - Passed" | tee -a ${COMPLIANCE}
			unset IFS
		else
		        echo "GEN000460 - Failed" | tee -a ${COMPLIANCE}
                        fix_system
                                if [ $? != 0 ]; then
                                        echo "Fix Failed" | tee -a ${FIX}
                                        restore_system
                                fi
                fi
                ;;
        "Check")
                #Checks STIG ID - GEN000460 the Red Hat Enterprise Linux 5 STIG to see if its compliant
                if [ ! -f ${C9FILE2} ]; then
                        cp ${C9FILE3} ${C9FILE2}
                fi
                for W in ${C9LINE}; do
                        C9CMD=`gawk "$W" ${C9FILE2}`
                        if [ "${C9CMD}x" == "x" ]; then
                                W=`echo $W | sed 's/\[\[\:space\:\]\]/\\\t/'g | sed 's/\///'g`
                                if [ "`echo ${NOTINFILE}`x" == x ];then
                                        NOTINFILE="$W"
                                else
                                        NOTINFILE="$NOTINFILE,$W"
                                fi
                        fi
                done
                if [ "${NOTINFILE}x" == "x" ] && [ "${C9COMMAND}" == "/etc/pam.d/system-auth-local" ]; then
                        echo "GEN000460 - Passed" | tee -a ${COMPLIANCE}
                        unset IFS
                else
                        echo "GEN000460 - Failed" | tee -a ${COMPLIANCE}
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
