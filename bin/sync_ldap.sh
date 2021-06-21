#!/usr/bin/env sh

# This is designed for a machine running OSX and connected to both Google's LDAP and our local LDAP. It will export users and groups from Google and import to our local system. It takes one further step and removes anybody who's suspended in Google from the local LDAP
# At present this is merge-ONLY. It will NOT remove people from groups, it will only add them.

USER="${1}"
PASS="${2}"

if [ ! ${USER} -o ! ${PASS} ]; then
  echo "usage: sync_ldap.sh USER PASSWORD"
  exit 1
fi

EXPLO="gringotts.explo.org"
EXPLO_LDAP="/LDAPv3/${EXPLO}"
GOOGLE_LDAP="/LDAPv3/ldap.google.com"
SYNC_GROUPS="portico_director,portico_curriculum,portico_rd,portico_banker,portico_shopper,portico_staff,portico_triage"
WORKDIR="/tmp"

# export google users, but don't sync/overwrite password
dsexport "${WORKDIR}/users.all" --N "${GOOGLE_LDAP}" dsRecTypeStandard:Users -e dsAttrTypeStandard:Password

# omit suspended folks
cat "${WORKDIR}/users.all" | awk '!/:true/{print $0}' > "${WORKDIR}/users"
wc -l "${WORKDIR}/users"
cat  "${WORKDIR}/users.all" | awk '/:true/{print $0}' > "${WORKDIR}/disabled_users"
wc -l "${WORKDIR}/disabled_users"
rm "${WORKDIR}/users.all"

echo

# export google groups
dsexport "${WORKDIR}/groups" "${GOOGLE_LDAP}" dsRecTypeStandard:Groups -r "${SYNC_GROUPS}"
wc -l "${WORKDIR}/groups"

# import google groups
echo "\nSynchronizing users..."
dsimport "${WORKDIR}/users" "/LDAPv3/127.0.0.1" M --remotehost "${EXPLO}" --remoteusername "${USER}" --remotepassword "${PASS}" --username "${USER}" --password "${PASS}" --outputfile "${WORKDIR}/users.log"

echo "\nRemoving disabled users from LDAP..."
cat "${WORKDIR}/disabled_users" | 
awk 'BEGIN{FS=":"}{print $5}' | 
xargs -I xXx dscl -u "${USER}" -P "${PASS}" "${EXPLO_LDAP}" -delete /Users/xXx > /dev/null 2> /dev/null

echo "Synchronizing groups..."
dsimport "${WORKDIR}/groups" "/LDAPv3/127.0.0.1" M --remotehost "${EXPLO}" --remoteusername "${USER}" --remotepassword "${PASS}" --username "${USER}" --password "${PASS}" --outputfile "${WORKDIR}/groups.log"
