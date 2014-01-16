# "Script Name" - Daniel Diserens <diserens@gdls.com>
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
RCSPATH="/data/share/client/rcsfiles"
RCSLOC=${RCSPATH}/inittab
UTILDIR="/root/Desktop/stig"
IFS=$','
C9DIR="/etc/pam.d"
C9FILE="${C9DIR}/system-auth"
C9FILE2="${C9DIR}/system-auth-local"
C9FILE3="${C9DIR}/system-auth-ac"
C9LINE='/auth[[:space:]]required[[:space:]]pam_access.so/,/auth[[:space:]]required[[:space:]]pam_tally2.so deny=3/,/auth[[:space:]]include[[:space:]]system-auth-ac/,/account[[:space:]]required[[:space:]]pam_tally2.so/,/account[[:space:]]include[[:space:]]system-auth-ac/,/password[[:space:]]include[[:space:]]system-auth-ac/,/session[[:space:]]include[[:space:]]system-auth-ac/'

#*******************************************************************************

#Function
complete_check ()
{
check_system

fix_system
}

#*******************************************************************************

check_system ()
{
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
if [ "${NOTINFILE}x" == "x" ] & [ "`ls -l ${C9FILE} | awk -F' ' '{print $11}'`" == "/etc/pam.d/system-auth-local" ]; then
        C9="T"
        echo "GEN000460 - Passed" | tee -a ${COMPLIANCE}
	unset IFS
else
        C9="F"
        echo "GEN000460 - Failed" | tee -a ${COMPLIANCE}
fi
}

#*******************************************************************************

fix_system ()
{
#Runs fix for STIG ID - GEN000460 the Red Hat Enterprise Linux 5 STIG
if [ "${C9}" == "F" ]; then
        echo "Fixing STIG ID - GEN000460"
	
	for W in ${NOTINFILE}; do
		if [ `echo $W | awk -F'\' '{ print $1 }'` == "auth" ];then
			C9CMD=`sed -e '/auth[[:space:]]*required[[:space:]]*pam_deny.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2} > ${C9FILE2}.tmp`
			${C9CMD}
			cp "${C9FILE2}.tmp" "${C9FILE2}"
		elif [ `echo $W | awk -F'\' '{ print $1 }'` == "account" ];then
	        	C9CMD1=`sed -e '/account[[:space:]]*required[[:space:]]*pam_permit.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2} > ${C9FILE2}.tmp`
			${C9CMD1}
			cp "${C9FILE2}.tmp" "${C9FILE2}"
		elif [ `echo $W | awk -F'\' '{ print $1 }'` == "password" ];then
  			C9CMD2=`sed -e '/password[[:space:]]*required[[:space:]]*pam_deny.so/{:a;n;/^$/!ba;i'$W'' -e '}' ${C9FILE2} > ${C9FILE2}.tmp`
			C9CND3=`sed -e '/password[[:space:]]*sufficient[[:space:]]*pam_unix.so/{`
			
			${C9CMD2}
			cp "${C9FILE2}.tmp" "${C9FILE2}"
		else
			echo -e "$W" >> ${C9FILE2}
		fi
	done
	unset IFS
	if [ `ls -l ${C9FILE} |awk -F' ' '{print $11}'` == /etc/pam.d/system-auth-ac ]; then
		unlink ${C9FILE}
		cp ${C9FILE3} ${C9FILE2}.tmp
	else
		cp ${C9FILE3} ${C9FILE2}.tmp
	fi
	ln -s ${C9FILE2} ${C9FILE}
fi
}

#*******************************************************************************

restore_system ()
{
unlink ${C9FILE}
cp ${C9FILE2}.tmp ${C9FILE3}
ln -s ${C9FILE3} ${C9FILE}
}

#*******************************************************************************

if [[ "$1" = "-a" ]]; then
        complete_check
        if [ $? != 0 ]; then
		echo "Check Failed" | tee -a ${COMPLIANCE}
                restore_system
        fi
elif [[ "$1" = "-c" ]]; then
        check_system
elif [[ "$1" = "-f" ]]; then
        fix_system
        if [ $? != 0 ]; then
		echo "Fix Failed" | tee -a ${COMPLIANCE}
                restore_system
        fi
elif [[ "$1" = "-r" ]]; then
        restore_system $2
else
        echo "You have entered an invalid switch"
fi
