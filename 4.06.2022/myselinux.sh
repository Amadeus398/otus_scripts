#!/bin/bash

ROOT_UID=0
E_NOTROOT=67

#########################
# The command line help #
#########################
display_help() {
  echo "This tool shows the SELinux status. Also, this tool can"
  echo "enable or disable SELinux if you have root privileges."
  echo ""
  echo ""
  echo "Usage: [myselinux.sh] [option]"
  echo "Checks the system for the operations of the SELinux service"
  echo ""
  echo "  -h, --help          open help"
  echo ""
  echo "  -s, --status        SELinux status"
  echo ""
  echo "  -a, --activation    SELinux activation. Only a user with root"
  echo "                      privileges can change the SELinux policy rules."
  echo ""
  echo "  -e, --enable        enable the SELinux in config. Only a user with root"
  echo "                      privileges can enable SELinux."
  echo ""
  echo "  -d, --disable       disable the SELinux in config. Only a user with root"
  echo "                      privileges can disable SELinux."
}

#########################
# Check root privileges #
#########################
check_root() {
  if [ "$UID" -ne "$ROOT_UID" ]; then
      echo "Only a user with root privileges can use this command"
      exit $E_NOTROOT
  fi
}

########################
# Check SELinux status #
########################
selinux_status() {
  sestatus
}

###########################################
# Question permissive SELinux policy rules #
###########################################
question_permissive() {
  echo "Do you want to change SELinux policy rules to permissive? (y/n):"
  read answer
  case "$answer" in
  [Yy])
    sudo setenforce 0
    echo "Selinux policy rules is $(getenforce)"
    ;;
  [Nn])
    echo "No changes. SELinux policy rules is $(getenforce)"
    ;;
  *)
    echo "Invalid argument: $answer"
    question_permissive
    ;;
  esac
}

###########################################
# Question enforcing SELinux policy rules #
###########################################
question_enforcing() {
  echo "Do you want to change SELinux policy rules to enforcing? (y/n):"
  read answer
  case "$answer" in
  [Yy])
    sudo setenforce 1
    echo "Selinux policy rules is $(getenforce)"
    ;;
  [Nn])
    echo "No changes. SELinux policy rules is $(getenforce)"
    ;;
  *)
    echo "Invalid argument: $answer"
    question_enforcing
    ;;
  esac
}

############################
# Check SELinux activation #
############################
selinux_activation() {
  SELINUX_STATE=$(getenforce)
  if [ "$SELINUX_STATE" == "Enforcing" ]; then
      echo "SELinux is activated. The SELinux policy rules is enforcing."
      question_permissive
  elif [ "$SELINUX_STATE" == "Permissive" ]; then
      echo "SELinux is activated. The SELinux policy rules is permissive."
      question_enforcing
  else
    echo "SELinux is disabled."
  fi
}

##############################
# Repeat the reboot question #
##############################
confirm_reboot() {
  echo "Reboot now? (y/n):"
  read answer
  case "$answer" in
  [Yy])
    sudo reboot
    ;;
  [Nn])
    echo "don't reboot now"
    ;;
  *)
    echo "Invalid argument: $answer"
    confirm_reboot
    ;;
  esac
}

##################
# Enable SELinux #
##################
selinux_enable() {
  SELINUX_STATE=$(getenforce)
  if [ "$SELINUX_STATE" != "Disabled"  ]; then
      echo "SELinux is already enabled."
  else
      sudo sed -i "s/^SELINUX=.*$/SELINUX=enforcing/" /etc/selinux/config && \
      echo "SELinux is enabled. This changes will be applied only after reboot."

      confirm_reboot
  fi
}

###################
# Disable SELinux #
###################
selinux_disable() {
  SELINUX_STATE=$(getenforce)
  if [ "$SELINUX_STATE" == "Disabled"  ]; then
      echo "SELinux is already disabled."
  else
      sudo sed -i "s/^SELINUX=.*$/SELINUX=disabled/" /etc/selinux/config && \
      echo "SELinux is disabled. This changes will be applied only after reboot."

      confirm_reboot
  fi
}

#################################
# Check if parameters options   #
# are given on the command line #
#################################
while :
do
  case "$1" in
  -h | --help)
    display_help
    exit 0
    ;;
  -s | --status)
    selinux_status
    exit 0
    ;;
  -a | --activation)
    check_root && \
    selinux_activation
    exit 0
    ;;
  -e | --enable)
    check_root && \
    selinux_enable
    exit 0
    ;;
  -d | --disable)
    check_root && \
    selinux_disable
    exit 0
    ;;
  *)
    echo "Error: invalid option: $1"
    echo ""
    display_help
    exit 1
    ;;
  esac
done