#!/bin/bash

# phantom_setup.sh runs before phenv/enable have been established.
PHANTOM_HOME=/opt/phantom
PHANTOM_VAR=/var

YUMCONF=/etc/yum.repos.d/phantom.repo
YUMCONF_BACKUP=/etc/yum.repos.d/phantom.repo.phantombak
CMD=
NOPROMPT=
WITHOUT_APPS=
IS_INSTALLED=
VER=
GITPKG=git
MINGIT=
RHSC_PSQL=
CLUSTER_ENABLED=
CLUSTER_NOTIFY=
NOTIFY_MSG="Notify mode = False"
PLATFORM=


umask 0022

if [[ "$EUID" != "0" ]]; then
  echo Error: must run with root privileges
  exit 1
fi

if [[ ! -f $YUMCONF ]]; then
  echo Error: could not find $YUMCONF
  exit 2
fi

PLATFORM_ERR=
if [[ $(cat /etc/redhat-release | grep "Red Hat") ]]; then
  if [[ $(cat /etc/redhat-release | grep "release 6") ]]; then
    PLATFORM=rhel6
  elif [[ $(cat /etc/redhat-release | grep "release 7") ]]; then
    PLATFORM=rhel7
  else
    PLATFORM_ERR=1
  fi
elif [[ $(cat /etc/redhat-release | grep "CentOS") ]]; then
  if [[ $(cat /etc/redhat-release | grep "release 6") ]]; then
    PLATFORM=centos6
  elif [[ $(cat /etc/redhat-release | grep "release 7") ]]; then
    PLATFORM=centos7
  else
    PLATFORM_ERR=1
  fi
else
    PLATFORM_ERR=1
fi

if [[ "$PLATFORM_ERR" != "" ]]; then
  echo "Error: Could not identify OS.  Must install on CentOS or RHEL 6/7"
fi

# Define functions

function usage() {
  echo "Usage:  "
  echo "   phantom_setup.sh install [--no-prompt] [--without-apps] [--version=VERSION] [--yumopts=\"...\"] [--mingit] [--rhsc-psql]"
  echo
  echo "     --no-prompt: proceed with installation/upgrade without confirmation prompt"
  echo "     --without-apps: do not automatically install default apps"
  echo "     --version: phantom version to install"
  echo "     --yumopts: additional parameters to pass to yum"
  echo "     --mingit:  installs minimal git package without perl Git module"
  echo "     --rhsc-psql:  installs PostgreSQL from Red Hat Source Collections"
  echo
  echo "   phantom_setup.sh upgrade [--no-prompt] [--without-apps] [--version=VERSION] [--yumopts=\"...\"]"
  echo
  exit 3
}

function interrupt() {
  echo "Interrupted.  Exiting"
  echo
  if [[ -f $YUMCONF_BACKUP ]]; then
    mv "$YUMCONF_BACKUP" "$YUMCONF"
  fi
  exit 4
}

function yum_fail() {
  CLEAN_ERR=$(cat /tmp/phantomInstall.err | sed 's/https:\/\/\([^@]*\)@/https:\/\/***@/')
  printf "\n\n%s\n\n%s\n" "$2" "${CLEAN_ERR}"
  mv "$YUMCONF_BACKUP" "$YUMCONF" 2>&1
  rm -f /tmp/phantomInstall.err 2>&1
  exit $1
}

function existing_dir_path {
  if [[ -d $1 ]]; then
    eval "$2='$1'"
  elif [[ $(dirname $1) = $1 ]]; then
    eval "$2='/'"
  else
    existing_dir_path $(dirname $1) $2
  fi
}


function check_disk() {
  DIRCHECK=
  existing_dir_path "$1" DIRCHECK
  local EXPECTED_SIZE=$2

  SIZE=$(df -m -P "${DIRCHECK}" | awk '{print $2}' | tail -n 1)
  if [[ ${SIZE} -lt "${EXPECTED_SIZE}" ]];  then
    printf "\n\n%s\n\n" "WARNING!  Available space on ${DIRCHECK} is ${SIZE} MB. Minimum space of ${EXPECTED_SIZE} MB expected"
  fi
}

# Parse parameters

for i in "$@"
do
case $i in
  install)
    if [[ $CMD ]]; then
      usage
    fi
    CMD=install
    ;;
  upgrade)
    if [[ $CMD ]]; then
      usage
    fi
    CMD=update
    ;;
  uninstall)
    if [[ $CMD ]]; then
      usage
    fi
    CMD=erase
    ;;
  --no-prompt)
    NOPROMPT=1
    ;;
  --without-apps)
    WITHOUT_APPS=1
    ;;
  --version=*)
    V=$(echo $i | sed 's/[-a-zA-Z0-9]*=\(.*\)/\1/')
    if [[ $V = "" ]]; then
      usage
    elif [[ ! "$V" =~ ([0-9]+).([0-9]+).([0-9]+)-([0-9]+) ]]; then
      echo "Invalid Version string '${V}'.  Expected Major.Minor.Patch-BuildNum"
      exit 5
    fi
    NEW_MAJOR="${BASH_REMATCH[1]}"
    NEW_MINOR="${BASH_REMATCH[2]}"
    NEW_PATCH="${BASH_REMATCH[3]}"
    NEW_BLDNUM="${BASH_REMATCH[4]}"
    VER="-${V}"
    ;;
  --yumopts=*)
    YUM_OPTS=$(echo $i | sed 's/[-a-zA-Z0-9]*=\(.*\)/\1/')
    if [[ $YUM_OPTS = "" ]]; then
      usage
    fi
    ;;
  --mingit)
    MINGIT=1
    GITPKG=git-min
    ;;
  --rhsc-psql)
    RHSC_PSQL=1
    ;;
  *)
    usage
esac
done

if [[ $VER != "" ]] && [[ $CMD = "erase" ]]; then
  echo "Version parameter invalid for uninstall"
  exit 5
fi

if [[ $VER != "" ]] && [[ $CMD = "update" ]]; then
  CURVER=`phenv python2.7 -c "from phantom_ui.product_version import PRODUCT_VERSION;print PRODUCT_VERSION"`
  export MAJOR=`echo $CURVER | cut -d . -f 1`
  export MINOR=`echo $CURVER | cut -d . -f 2`
  export PATCH=`echo $CURVER | cut -d . -f 3`
  export BUILD=`echo $CURVER | cut -d . -f 4`

  VERSION_FAIL=
  if [[ $NEW_MAJOR -lt $MAJOR ]]; then
    VERSION_FAIL=1
  elif [[ $NEW_MAJOR -eq $MAJOR ]] && [[ $NEW_MINOR -lt $MINOR ]]; then
    VERSION_FAIL=1
  elif [[ $NEW_MAJOR -eq $MAJOR ]] && [[ $NEW_MINOR -eq $MINOR ]] && [[ $NEW_PATCH -le $PATCH ]]; then
    VERSION_FAIL=1
  fi

  if [[ $VERSION_FAIL != "" ]]; then
    echo "Invalid version: $V .  Current version is $CURVER"
    exit 5
  fi
fi

if [[ $CMD = "" ]]; then
  usage
fi

if [[ $CMD = "erase" && $WITHOUT_APPS != "" ]]; then
  echo Invalid parameter combination
  usage
fi

rpm -q phantom > /dev/null
if [[ $? == 0 ]]; then
  IS_INSTALLED=1
fi

if [[ $IS_INSTALLED != "" && $CMD == "install" ]]; then
  echo Phantom is already installed
  usage
fi

if [[ $IS_INSTALLED == "" ]]; then
  if [[ $CMD == "update" || $CMD == "erase" ]]; then
    echo Phantom is not installed
    usage
  fi
fi

if [[ $MINGIT != "" ]] && [[ $CMD != "install" ]]; then
  echo "mingit parameter only valid for first time installation"
  exit 5
fi

if [[ $RHSC_PSQL != "" ]] && [[ $CMD != "install" ]]; then
  echo "rhsc-psql parameter only valid for first time installation"
  exit 5
fi

if [[ $RHSC_PSQL != "" ]]; then
  if [[ ! $(cat /etc/redhat-release | grep "Red Hat") ]]; then
    echo "rhsc-psql parameter only valid on Red Hat Enterprise Linux"
    exit 5
  fi
fi

if [[ $CMD = "update" ]]; then
  rpm -q git-min > /dev/null 2>&1
  if [[ $? = 0 ]]; then
    GITPKG=git-min
  fi
fi

# log stdout/stderr to ${PHANTOM_VAR}/log/phantom/phantom_install_log
{

# Prompt to confirm operation

echo
echo -n "Running $0 "
for i in "$@"
do
  echo -n "'$i' "
done
echo
date
echo
if [[ $NOPROMPT = "" ]]; then
  FILESIZE_MB=500000 #500GB
  check_disk ${PHANTOM_HOME}/data 20000
  check_disk ${PHANTOM_HOME} ${FILESIZE_MB}
  check_disk ${PHANTOM_VAR}/log/phantom 10000
  check_disk ${PHANTOM_HOME}/vault 20000

  REMOTE_DATABASE="false"
  REMOTE_SPLUNK="false"

  CONF_FILE=${PHANTOM_HOME}/etc/phantom_install.conf

  # if this is a new install , the conf file may not exist.  Splunk and DB
  # services are expected to be local
  if [[ -f ${CONF_FILE} ]]; then

    if grep -xq "REMOTE_DATABASE[[:space:]]*=[[:space:]]*true" ${CONF_FILE}
    then
      REMOTE_DATABASE="true"
    fi

    if grep -xq "REMOTE_SPLUNK[[:space:]]*=[[:space:]]*true" ${CONF_FILE}
    then
      REMOTE_SPLUNK="true"
    fi
  fi 

  if [[ "${REMOTE_DATABASE}" == "false" ]]; then
    # check disk space for local database filesystem
    check_disk ${PHANTOM_HOME}/data/db ${FILESIZE_MB}
  fi

  if [[ "${REMOTE_SPLUNK}" == "false" ]]; then
    # check disk space for local splunk filesystem
    check_disk ${PHANTOM_HOME}/data/splunk ${FILESIZE_MB}
  fi

  if [[ ! $(cat /etc/redhat-release | grep "CentOS") ]] && [[ ! $(cat /etc/redhat-release | grep "Red Hat") ]]; then
    printf "\n\n%s\n\n" "WARNING!  OS does not match CentOS or Red Hat:  $(cat /etc/redhat-release)"
  fi

  echo About to proceed with Phantom $CMD
  echo "Do you wish to proceed [y/N]  "
  read -r proceed

  if [[ $proceed != "y" ]]; then
    echo Operation canceled
    exit 5
  fi
fi

# patch stop_phantom.sh script
sed -i 's/"${REMOTE_SPLUNK:=1}" -ne 0/${REMOTE_SPLUNK} == 0/' "${PHANTOM_HOME}/bin/stop_phantom.sh"

# Prompt for YUM authentication credentials

unset entry_passwd
charcount=0
echo -n "Enter username: "
read -r entry_user
prompt="Enter password: "
while IFS= read -p "$prompt" -r -s -n 1 char
do
  if [[ $char == $'\0' ]]
  then
    break
  fi
  if [[ $char == $'\177' ]] ; then
    if [ $charcount -gt 0 ]; then
      charcount=$((charcount-1))
      prompt=$'\b \b'
      entry_passwd="${entry_passwd%?}"
    else
      prompt=''
    fi
  else
    charcount=$((charcount+1))
    prompt='*'
    entry_passwd+="$char"
  fi
done
echo


# Encode auth credentials

escaped_user=$(printf '%s' "$entry_user" | sed "s/'/\\\\'/")
escaped_passwd=$(printf '%s' "$entry_passwd" | sed "s/'/\\\\'/")
encoded_user=$(python -c "import urllib; print (urllib.quote('''$escaped_user''', safe=''))")
encoded_passwd=$(python -c "import urllib; print (urllib.quote('''$escaped_passwd''', safe=''))")


# Handle interrupt signals

trap interrupt INT TERM


# Update YUM configuration

mv "$YUMCONF" "$YUMCONF_BACKUP"
sed s/https\:\\/\\/repo\.phantom\.us/https:\\/\\/${encoded_user}:${encoded_passwd}@repo.phantom.us/g "$YUMCONF_BACKUP" > "$YUMCONF"


# Clean YUM data

yum --enablerepo=phantom\* --enablerepo=alternatives-phantom clean all 2>/tmp/phantomInstall.err
if [[ $? != 0 ]]; then
  yum_fail 6 "Error connecting to Phantom YUM repositories"
fi
>/tmp/phantomInstall.err

# Update Phantom Repo package

if [[ $V != "" ]]; then
  yum --showduplicates list phantom_repo | grep "$V" > /dev/null
  if [[ $? != 0 ]]; then
    yum_fail 5 "Failed to find phantom_repo package with version $V"
  fi
  REPOVER=$(rpm -q phantom_repo --info | grep Version | awk '{print $3}')
  if [[ $V != *${REPOVER}* ]]; then
    yum_fail 12 "Must install phantom_repo version $V to upgrade Phantom to $V"
  fi
fi

echo Updating phantom repo package
CURRENTREPO=$(rpm -qa | grep phantom_repo-)
yum --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS info "phantom_repo${VER}" >/dev/null 2>/tmp/phantomInstall.err
STATUS=$?

grep "error: 401" /tmp/phantomInstall.err >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
  yum_fail 7 "Error: YUM authentication failed"
fi

grep "cert cannot be verified" /tmp/phantomInstall.err >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
  yum_fail 8 "Error: Could not validate YUM server certificate"
fi

if [[ $STATUS != 0 ]]; then
  yum_fail 9 "Error updating Phantom Repo package $YUM_OPTS $VER"
fi
>/tmp/phantomInstall.err

UPDATEDREPO=$(rpm -qa | grep phantom_repo-)
if [[ $CURRENTREPO != $UPDATEDREPO ]]; then
  sed s/https\:\\/\\/repo\.phantom\.us/https:\\/\\/${encoded_user}:${encoded_passwd}@repo.phantom.us/g "$YUMCONF_BACKUP" > "$YUMCONF"
fi

# check cluster upgrade mode
if [ "$CMD" = "update" ]; then
  if [ -f ${PHANTOM_HOME}/bin/is_clustering_enabled.pyc ]; then
    phenv python ${PHANTOM_HOME}/bin/is_clustering_enabled.pyc
    if [[ $? -eq 0 ]]; then
      CLUSTER_ENABLED=1
      NEW_VERSION=$(rpm -q phantom_repo --info | grep Version | awk '{print $3}')
      phenv python ${PHANTOM_HOME}/lib/phantom/cluster_upgrade.pyc --get-upgrade-mode-notify --version="$NEW_VERSION"
      if [[ $? -eq 0 ]]; then
        CLUSTER_NOTIFY=1
        NOTIFY_MSG="Notify mode = True"
      fi
      echo "Upgrading cluster node. $NOTIFY_MSG"
      if [ "$CLUSTER_NOTIFY" != "" ]; then
        phenv python ${PHANTOM_HOME}/lib/phantom/cluster_upgrade.pyc --disable-nodes --version="$NEW_VERSION"
      fi
    fi
  fi
fi

# Install/Upgrade phantom_rh_postgresql94 if necessary

if [[ $CMD = "install" ]] && [[ $RHSC_PSQL != "" ]]; then
  yum --enablerepo=alternatives-phantom --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS $CMD phantom_rh_postgresql94 2>/tmp/phantomInstall.err
  if [[ $? != 0 ]]; then
    yum_fail 10 "Failed to install phantom_rh_postgresql94"
  fi
  >/tmp/phantomInstall.err
fi

rpm -qa | grep phantom_rh_postgresql94 > /dev/null 2>&1
if [[ $? = 0 && $CMD = "update" ]]; then
  echo updating phantom_rh_postgresql94
  yum --enablerepo=alternatives-phantom --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS $CMD phantom_rh_postgresql94 2>/tmp/phantomInstall.err
  if [[ $? != 0 ]]; then
    yum_fail 10 "Failed to upgrade phantom_rh_postgresql94"
  fi
  >/tmp/phantomInstall.err
fi

if [[ $V != "" ]]; then
  yum --enablerepo=phantom-product --enablerepo=phantom-base --showduplicates list phantom | grep "$V" > /dev/null
  if [[ $? != 0 ]]; then
    yum_fail 5 "Failed to find phantom package with version $V"
  fi
fi

if [[ $CMD = "install" ]] || [[ $CMD = "update" ]]; then
  # Run YUM command for git package
  printf "\n\n%s\n\n" "Running $CMD for $GITPKG"
  sleep 4
  yum --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS $CMD $GITPKG 2>/tmp/phantomInstall.err
  STATUS=$?
  if [[ $STATUS != 0 ]]; then
    yum_fail 11 "Failed to run $CMD $YUM_OPTS for $GITPKG"
  fi
  >/tmp/phantomInstall.err
fi

if [[ $CMD = "install" ]] || [[ $CMD = "update" ]]; then
  # Run YUM command for postgresql packages
  printf "\n\n%s\n\n" "Running $CMD for postgresql94-server"
  sleep 4
  yum --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS $CMD postgresql94-server 2>/tmp/phantomInstall.err
  STATUS=$?
  if [[ $STATUS != 0 ]]; then
    yum_fail 11 "Failed to run $CMD $YUM_OPTS for postgresql94-server"
  fi
  >/tmp/phantomInstall.err
fi

printf "\n\n%s\n\n%s\n\n" "Running $CMD for phantom packages" "This will take some time..."
yum --enablerepo=phantom-product --enablerepo=phantom-base -y $YUM_OPTS $CMD phantom-python \
  "phantom${VER}" \
  "phantom_cacerts${VER}" \
  "phantom_cluster${VER}" \
  "phantom_dependencies${VER}" \
  "phantom_local${VER}.${PLATFORM}" \
  "phantom_pylib${VER}" \
  2>/tmp/phantomInstall.err
STATUS=$?
if [[ $STATUS != 0 ]]; then
  yum_fail 11 "Failed to run $CMD $YUM_OPTS for phantom $VER"
fi
>/tmp/phantomInstall.err

# Install Phantom apps unless disabled
if [[ $STATUS = 0 && $WITHOUT_APPS -eq "" ]]; then
  # install apps unless clustering is enabled
  if [ "$CLUSTER_ENABLED" = "" ]; then
    echo Installing phantom apps

    phenv python ${PHANTOM_HOME}/bin/install_initial_apps.py --all 2>/tmp/phantomInstall.err
    STATUS=$?
    if [[ $STATUS != 0 ]]; then
      yum_fail $STATUS "Failure during phantom app installation"
    fi
    >/tmp/phantomInstall.err
  fi
  >/tmp/phantomInstall.err
fi


# Restore original YUM configuration

mv "$YUMCONF_BACKUP" "$YUMCONF"
rm -f /tmp/phantomInstall.err 2>/dev/null

if [[  $CMD == "update" ]]; then
  if [ "$CLUSTER_ENABLED" != "" ]; then
    if [ "$CLUSTER_NOTIFY" != "" ]; then
      phenv python ${PHANTOM_HOME}/lib/phantom/cluster_upgrade.pyc --enable-nodes
    fi
  fi
fi
# Complete

echo -n "Completed $0 "
for i in "$@"
do
  echo -n "'$i' "
done
echo
date

echo exit $STATUS
exit $STATUS

# log stdout/stderr to ${PHANTOM_VAR}/phantom/phantom_install_log
} 2>&1 | tee -ia ${PHANTOM_VAR}/log/phantom/phantom_install_log && exit $PIPESTATUS
