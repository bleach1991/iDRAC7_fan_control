#!/bin/bash
#
# https://github.com/brezlord/iDRAC7_fan_control
# A simple script to control fan speeds on Dell generation 12 PowerEdge servers. 
# If the CPU temperature is above 100deg C enable iDRAC dynamic control and exit program.
# If CPU temp is below 100deg C set fan control to manual and set fan speed to predetermined value.
# The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will
# be higher than the ambient temperature.

# Variables
IDRAC_IP="IP address of iDRAC"
IDRAC_USER="user"
IDRAC_PASSWORD="passowrd"
# Fan speed in %
SPEED0="0x00"
SPEED5="0x05"
SPEED10="0x0a"
SPEED15="0x0f"
SPEED20="0x14"
SPEED25="0x19"
SPEED30="0x1e"
SPEED35="0x23"
TEMP_THRESHOLD="100" # iDRAC dynamic control enable thershold
TEMP_SENSOR_INLET="04h"   # Inlet Temp
TEMP_SENSOR_EXHAUST="01h"  # Exhaust Temp
TEMP_SENSOR_CPU1="0Eh"  # CPU 1 Temp
TEMP_SENSOR_CPU2="0Fh"  # CPU 2 Temp

# Get system date & time.
DATE=$(date +%Y-%m-%d\ %H:%M:%S)
echo "Date ${DATE}"

# Get temperature from iDARC.
ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} sdr type temperature > /tmp/dell_temperature

TEMP_INLET=$(cat /tmp/dell_temperature | grep ${TEMP_SENSOR_INLET} | cut -d"|" -f5 | cut -d" " -f2)
TEMP_EXHAUST=$(cat /tmp/dell_temperature | grep ${TEMP_SENSOR_EXHAUST} | cut -d"|" -f5 | cut -d" " -f2)
TEMP_CPU1=$(cat /tmp/dell_temperature | grep ${TEMP_SENSOR_CPU1} | cut -d"|" -f5 | cut -d" " -f2)
TEMP_CPU2=$(cat /tmp/dell_temperature | grep ${TEMP_SENSOR_CPU2} | cut -d"|" -f5 | cut -d" " -f2)

((T=(TEMP_CPU1+TEMP_CPU1)/2))


echo "--> iDRAC IP Address: ${IDRAC_IP}"
echo "--> Current CPU Temp: ${T}"

# Set fan speed dependant on ambient temperature if CPU temperaturte is below 100deg C.
# If CPU temperature between 1 and 60deg C then set fans to 10%.
if [ "${T}" -ge 1 ] && [ "${T}" -le 59 ]
then
  echo "--> Setting fan speed to 10%"
  ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} raw 0x30 0x30 0x02 0xff $SPEED10

# If CPU temperature between 60 and 69deg C then set fans to 15%
elif [ "${T}" -ge 60 ] && [ "${T}" -le 69 ]
then
  echo "--> Setting fan speed to 15%"
  ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} raw 0x30 0x30 0x02 0xff $SPEED15

# If CPU temperature between 70 and 79deg C then set fans to 20%
elif [ "${T}" -ge 70 ] && [ "${T}" -le 79 ]
then
  echo "--> Setting fan speed to 20%"
  ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} raw 0x30 0x30 0x02 0xff $SPEED20

# If CPU temperature between 80 and 89deg C then set fans to 25%
elif [ "${T}" -ge 80 ] && [ "${T}" -le 89 ]
then
  echo "--> Setting fan speed to 25%"
  ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} raw 0x30 0x30 0x02 0xff $SPEED25

# If CPU temperature between 90 and 99deg C then set fans to 30%
elif [ "${T}" -ge 90 ]
then
  echo "--> Setting fan speed to 30%"
  ipmitool -I lanplus -H ${IDRAC_IP} -U ${IDRAC_USER} -P ${IDRAC_PASSWORD} raw 0x30 0x30 0x02 0xff $SPEED30
fi
