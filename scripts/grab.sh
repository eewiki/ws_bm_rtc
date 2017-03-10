#!/bin/bash

port="/dev/ttyUSB0"

stty -F ${port} raw speed 57600 &> /dev/null

# Loop
while [ 1 ];
do
	READ=` grabserial -d /dev/ttyUSB0 -b 57600 -m "$" -q "^\n"`
	echo "[$READ]"
	load_busvolt=$(echo $READ | sed 's/ /\n/g' | grep '$LOAD:' | grep BusVolt | tail -1 | awk -F ':' '{print $4}' | awk -F 'V*' '{print $1}' || true)
	echo "load_busvolt=[$load_busvolt]"
	load_current=$(echo $READ | sed 's/ /\n/g' | grep '$LOAD:' | grep Current | tail -1 | awk -F ':' '{print $4}' | awk -F 'mA*' '{print $1}' || true)
	echo "load_current=[$load_current]"

	charger_busvolt=$(echo $READ | sed 's/ /\n/g' | grep '$CHARGER:' | grep BusVolt | tail -1 | awk -F ':' '{print $4}' | awk -F 'V*' '{print $1}' || true)
	echo "charger_busvolt=[$charger_busvolt]"
	charger_current=$(echo $READ | sed 's/ /\n/g' | grep '$CHARGER:' | grep Current | tail -1 | awk -F ':' '{print $4}' | awk -F 'mA*' '{print $1}' || true)
	echo "charger_current=[$charger_current]"

#$WBH:23:Humid:22.43P*
#$WBP:23:Pres:99554.00Pa*
#$WBT:23:TempF:14.11F*

	wbh=$(echo $READ | sed 's/ /\n/g' | grep '$WBH:' | grep Humid | tail -1 | awk -F ':' '{print $4}' | awk -F 'P*' '{print $1}' || true)
	echo "wbh=[$wbh]"
	wbp=$(echo $READ | sed 's/ /\n/g' | grep '$WBP:' | grep Pres | tail -1 | awk -F ':' '{print $4}' | awk -F 'Pa*' '{print $1}' || true)
	echo "wbp=[$wbp]"
	wbt=$(echo $READ | sed 's/ /\n/g' | grep '$WBT:' | grep TempF | tail -1 | awk -F ':' '{print $4}' | awk -F 'F*' '{print $1}' || true)
	echo "wbt=[$wbt]"


	get_time=$(env TZ=America/North_Dakota/Center date +"%Y/%m/%d %k:%M:%S")

	if [ "x$load_busvolt" != "x" ] && [ "x$load_current" != "x" ] ; then
		echo "$get_time,$load_busvolt" >> /var/www/html/dygraphs/load_voltage_data.csv
		echo "$get_time,$load_current" >> /var/www/html/dygraphs/load_current_data.csv
		if [ "x$charger_busvolt" != "x" ] ; then
			echo "$get_time,$load_busvolt,$charger_busvolt" >> /var/www/html/dygraphs/voltage_data.csv
			echo "save:[$get_time,$load_busvolt,$charger_busvolt]"
		fi
	fi

	if [ "x$charger_busvolt" != "x" ] && [ "x$charger_current" != "x" ] ; then
		echo "$get_time,$charger_busvolt" >> /var/www/html/dygraphs/charger_voltage_data.csv
		echo "$get_time,$charger_current" >> /var/www/html/dygraphs/charger_current_data.csv
		if [ "x$load_current" != "x" ] ; then
			echo "$get_time,$load_current,$charger_current" >> /var/www/html/dygraphs/current_data.csv
			echo "save:[$get_time,$load_current,$charger_current]"
		fi
	fi

	if [ "x$wbh" != "x" ] ; then
		echo "$get_time,$wbh" >> /var/www/html/dygraphs/wbh_data.csv
	fi

	if [ "x$wbp" != "x" ] ; then
		echo "$get_time,$wbp" >> /var/www/html/dygraphs/wbp_data.csv
	fi

	if [ "x$wbt" != "x" ] ; then
		echo "$get_time,$wbt" >> /var/www/html/dygraphs/wbt_data.csv
	fi
done
