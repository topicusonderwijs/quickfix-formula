#!/bin/bash

# This is a helper script for phasing out old routes. It is used for
# the pfsense -> fortigate migration at Topicus.Education.
# It can be used to remove all the obsolete routes to the pfsense,
# or restore them in case stuff goes haywire.

# set -e: exit on first error
# set -u: exit on unbound variable
set -eu

# Store the old "Inter Field Seperator" and set a new one. This is
# used to indicate what a new field is when iterating over strings.
# In this case, we want fields to be seperated by a newline.
OLDIFS=${IFS}
IFS='
'
BACKUP_DIR="/root/.obsolete_routes"
BACKUP_FILE="${BACKUP_DIR}/_runtime_routes.bak"
mkdir ${BACKUP_DIR} > /dev/null 2>&1 || true

function help() {
	echo "Usage $0:"
	echo " -h 	this help text"
	echo " -r	restore previous removed routes."
	echo " -d	dry-run, show what would have been removed."
	echo " -f	force, remove obsolete routes."
}

function backupObsoleteRuntimeRoutes(){
	echo "# Backup of obsolete routes via the pfsense firewall" > ${BACKUP_FILE}
	echo "# Created at $(date)" >> ${BACKUP_FILE}
	ip route show | grep -E "via 192.168.[[:digit:]]{2}.132" >> ${BACKUP_FILE}
}


function removeObsoleteConfiguredRoutes(){
	# Find all route configuration files in /etc/sysconfig/network-scripts/
	configFiles=$(find /etc/sysconfig/network-scripts/ -type f -iname "*route-*")
	for cfgFile in ${configFiles}; do
		# Check if it contains obsolete routes
		if $(grep -E "via 192.168.[[:digit:]]{2}.132" ${cfgFile} > /dev/null); then
			echo ">>> Found at least one obsolete rule in ${cfgFile}"
			# If this is a force:
			if [[ ${1} == "remove" ]]; then
				echo -n " - Backup: "
				cp -fv ${cfgFile} ${BACKUP_DIR}/ 
				echo " ---------- old content ----------"
				cat ${cfgFile}
				echo " ---------- new content ----------"
				sed -i -E '/192.168.[[:digit:]]{2}.132/d' ${cfgFile}
				cat ${cfgFile}
				echo " ------------ EOF ----------------"
			else
				echo " ---------- old content ----------"
				cat ${cfgFile}
				echo " ------ new content would be -----"
				sed -E '/192.168.[[:digit:]]{2}.132/d' ${cfgFile}
				echo " ------------ EOF ----------------"
			fi
			echo ""	
		else
			echo ">>> No obsolete rules found in ${cfgFile}"
		fi
	done
}

function removeObsoleteRuntimeRoutes(){
	# First check if there are runtime routes that are obsolete. We must do that this
	# way because we can not have unbound variables and the scripts exits when there
	# are no obsolete runtime routes.
	if [[ ! $(ip route show | grep -E "via 192.168.[[:digit:]]{2}.132") ]]; then
		echo ">>> No obsolete runtime routes found..."
		return
	else 
		OBSOLETE_ROUTES=$(ip route show | grep -E "via 192.168.[[:digit:]]{2}.132")
		if [[ ${1} == "remove" ]]; then
			backupObsoleteRuntimeRoutes
		fi
	fi


	# Then for each obsolete runtime route, remove or echo the route.
	for route in ${OBSOLETE_ROUTES}; do
		if [[ ${1} == "remove" ]]; then
			network=$(echo ${route} |cut -d' ' -f1)
			gateway=$(echo ${route} |cut -d' ' -f3)
			echo "Removing runtime route: ${network} via ${gateway}"
			ip route del ${network} via ${gateway}
		elif [[ ${1} == "dry_run" ]]; then
			echo ">>> I would remove runtime route: $route"
		else
			echo ">>> Error: expected argument in function..."
			exit 2
		fi
	done
}

function restoreObsoleteRuntimeRoutes(){
	ROUTES_TO_RESTORE=$(grep -v "#" ${BACKUP_FILE})
	for route in ${ROUTES_TO_RESTORE}; do
		network=$(echo ${route} |cut -d' ' -f1)
		gateway=$(echo ${route} |cut -d' ' -f3)
		echo "Adding route: ${network} via ${gateway}"
		ip route add ${network} via ${gateway} || true
	done
}

function restoreObsoleteConfiguredRoutes(){
	find ${BACKUP_DIR} -type f -iname "*route-*" -exec cp -fv {} /etc/sysconfig/network-scripts/ \;
}

###
# Main start
while getopts ":drfh" option; do
	case ${option} in 
		d) # dry-run
			removeObsoleteRuntimeRoutes dry_run
			removeObsoleteConfiguredRoutes dry_run
			exit 0
			;;
		r) # restore
			restoreObsoleteRuntimeRoutes
			restoreObsoleteConfiguredRoutes
			exit 0
			;;
		f) # force, delete obsolete routes.
			removeObsoleteRuntimeRoutes remove
			removeObsoleteConfiguredRoutes remove
			exit 0
			;;
		h) # help
			help
			exit 0
			;;
		\?) # Invalid argument.
			echo "Invalid argument, see -h for help"
			exit 1
			;;
	esac
done

help
exit 1

