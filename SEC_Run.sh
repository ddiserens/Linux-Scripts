#!/bin/bash 
################################################################################
# "SEC_Run.sh" - Daniel Diserens <diserens@gdls.com>
# Version 1.0
################################################################################
#  DESCRIPTION: This script runs all of the scripts			       #
################################################################################
#  NOTE:  Several variables are set and not used in this code.  This was done  #
#         intentionally, as I would like to make improvements later.           #
################################################################################
# set -x

#*******************************************************************************

#Variables

#*******************************************************************************

#Functions
SEC_Run ()
{
SCRIPT="/root/Desktop/stig/test/020_passwd_single_user.sh" 
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1 
fi

SCRIPT="/root/Desktop/stig/test/100_system_release.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/241_services.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/250_permissions.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/252_check_permissions.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/380_GID_passwd.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/400_banner.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/450_simultaneous_login.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/460_system_auth.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/500_screen_saver.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/540_login_def.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/560_system_auth_local.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/585_passwd_check.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/590_passwd_hash.sh"
if [ -x "${SCRIPT}" ]; then
        ${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/700_passwd_aging.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/750_passwd_diff.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/800_passwd_reuse.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/850_prevent_root.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/880_account_uid.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/900_root_dir.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/920_rootdir_perm.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/980_login_console.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1080_root_shell.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1120_remote_access.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1200_ww_files.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1220_program_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1240_program_group.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1260_logfile_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1300_library_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1320_nis_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1360_nis_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1362_resolv_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1364_resolv_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1366_hosts_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1368_hosts_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1371_nsswitch_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1372_nsswitch_group_own.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1373_nsswitch_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1378_passwd_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1379_passwd_group_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1380_passwd_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1391_group_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1392_group_group_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1393_group_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1400_shadow_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1410_shadow_group_owner.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1420_shadow_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1440_assign_home.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1460_create_home.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1470_passwd_hash.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1475_group_hash.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1480_home_perms.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi

SCRIPT="/root/Desktop/stig/test/1580_startup_perm.sh"
if [ -x "${SCRIPT}" ]; then
	${SCRIPT} $1
fi
}
