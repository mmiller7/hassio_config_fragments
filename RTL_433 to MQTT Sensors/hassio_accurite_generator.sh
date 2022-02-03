#!/bin/bash
s_f="output/generated_sensors.yaml"
bs_f="output/generated_binary_sensors.yaml"
p_f="output/generated_combined_package.yaml"
f_f="output/generated_sensors_filters.yaml"
fp_f="output/generated_sensors_filters_package.yaml"
lu_f="output/generated_sensors_last_updated.yaml"
lup_f="output/generated_sensors_last_updated_package.yaml"
sn_f="output/generated_sensors_signal.yaml"
snp_f="output/generated_sensors_signal_package.yaml"
#topic_base="homeassistant/sensor/rtl433/Acurite_tower_sensor"
topic_base="homeassistant/sensor/rtl433/Acurite-Tower"

# List of sensors
sensor_list=( "1234/Outside Front" "5678/Outside Rear" "4321/Downstairs Hall" "8765/Upstairs Hall" )


# Indoor sensors spec says -20 to +70C
# Outdoor sensors spec says -40C to +70C
# but most bad high values seem WAY high hundreds
temp_min_C=-20
temp_max_C=70


echo '' > $s_f
echo '' > $bs_f
echo '' > $p_f
echo '' > $f_f
echo '' > $fp_f
echo '' > $lu_f
echo '' > $lup_f
echo '' > $sn_f
echo '' > $snp_f

# here we go
echo ""
echo "Sensor filename: $s_f"
echo "Binary Sensor filename: $bs_f"
echo "package filename: $p_f"
echo "Filter filename: $f_f"
echo "Filter package filename: $fp_f"
echo "Last_Updated filename: $f_f"
echo "Last_Updated package filename: $fp_f"
echo "MQTT Topic Base: $topic_base"
echo ""
echo "Generating YAML..."

# Replace the items in the "for" line with "<decimal_id>/Name" for each sensor
for i in "${sensor_list[@]}"
do
	# compute variables from sensor list
	id=`echo $i | awk -F '/' '{ print $1 }'`
	name=`echo $i | awk -F '/' '{ print $2 }'`
	unique_id=`echo $name | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g'`

	# debug info
	echo "$name -> $id"

	# Main sensor temp/humidity

	# write out data to file
	echo "  # $name Sensor" >> $s_f
	echo "  - platform: mqtt" >> $s_f
	echo "    name: \"$name Temperature\"" >> $s_f
	echo "    unique_id: \"${unique_id}_temperature\"" >> $s_f
	echo "    device_class: temperature" >> $s_f
	echo "    force_update: true" >> $s_f
	echo "    state_topic: \"$topic_base/$id\"" >> $s_f
	echo "    unit_of_measurement: '°C'" >> $s_f
	echo "    value_template: >-" >> $s_f
	echo "      {% if value_json.temperature_C > $temp_min_C and value_json.temperature_C < $temp_max_C %}" >> $s_f
	echo "        {{ value_json.temperature_C }}" >> $s_f
	echo "      {% else %}" >> $s_f
	echo "        {{ states.sensor.${unique_id}_temperature.state }}" >> $s_f
	echo "      {% endif %}" >> $s_f


	echo "  - platform: mqtt" >> $s_f
	echo "    name: \"$name Humidity\"" >> $s_f
	echo "    unique_id: \"${unique_id}_humidity\"" >> $s_f
	echo "    device_class: humidity" >> $s_f
	echo "    icon: hass:water-percent" >> $s_f
	echo "    force_update: true" >> $s_f
	echo "    state_topic: \"$topic_base/$id\"" >> $s_f
	echo "    unit_of_measurement: '%'" >> $s_f
	echo "    value_template: >-" >> $s_f
	echo "      {% if value_json.humidity >= 0 and value_json.humidity <= 100 %}" >> $s_f
	echo "        {{ value_json.humidity }}" >> $s_f
	echo "      {% else %}" >> $s_f
	echo "        {{ states.sensor.${unique_id}_humidity.state }}" >> $s_f
	echo "      {% endif %}" >> $s_f
	echo "" >> $s_f

	# Main sensor low battery

	echo "  # $name Sensor" >> $bs_f
	echo "  - platform: mqtt" >> $bs_f
	echo "    name: \"$name Sensor Battery Low\"" >> $bs_f
	echo "    unique_id: \"${unique_id}_sensor_battery_low\"" >> $bs_f
	echo "    device_class: battery" >> $bs_f
	echo "    state_topic: \"$topic_base/$id\"" >> $bs_f
#	echo "    payload_on: \"1\"" >> $bs_f
#	echo "    payload_off: \"0\"" >> $bs_f
	echo "    payload_on: \"0\"" >> $bs_f
	echo "    payload_off: \"1\"" >> $bs_f
	echo "    value_template: >-" >> $bs_f
#	echo "      {% if value_json.battery_low == 0 or value_json.battery_low == 1 %}" >> $bs_f
#	echo "        {{ value_json.battery_low }}" >> $bs_f
#	echo "      {% else %}" >> $bs_f
#	echo "        {{ states.sensor.${unique_id}_battery_low.state }}" >> $bs_f
	echo "      {% if value_json.battery_ok == 1 or value_json.battery_ok == 0 %}" >> $bs_f
	echo "        {{ value_json.battery_ok }}" >> $bs_f
	echo "      {% else %}" >> $bs_f
	echo "        {{ states.sensor.${unique_id}_battery_ok.state }}" >> $bs_f
	echo "      {% endif %}" >> $bs_f
	echo "" >> $bs_f



	# custom filters for temp/humidity graph smoothing

	echo "  - platform: filter" >> $f_f
	echo "    name: \"$name Temperature Filtered\"" >> $f_f
	# this does not support unique_id
	# entity_id is the sensor to use for input to the filter
	echo "    entity_id: sensor.${unique_id}_temperature" >> $f_f
        echo "    filters:" >> $f_f
        echo "      - filter: outlier" >> $f_f
        echo "        window_size: 3" >> $f_f
        echo "        radius: 10.0" >> $f_f
        echo "      - filter: time_simple_moving_average" >> $f_f
        echo "        window_size: 00:01" >> $f_f
        echo "        precision: 1" >> $f_f

        echo "  - platform: filter" >> $f_f
	echo "    name: \"$name Humidity Filtered\"" >> $f_f
	# this does not support unique_id
	# entity_id is the sensor to use for input to the filter
	echo "    entity_id: sensor.${unique_id}_humidity" >> $f_f
        echo "    filters:" >> $f_f
        echo "      - filter: outlier" >> $f_f
        echo "        window_size: 3" >> $f_f
        echo "        radius: 10.0" >> $f_f
        echo "      - filter: time_simple_moving_average" >> $f_f
        echo "        window_size: 00:01" >> $f_f
        echo "        precision: 1" >> $f_f
        echo "" >> $f_f



	# custom last_updated sensor counter for watchdog or other stat use

	echo "  - platform: template" >> $lu_f
	echo "    sensors:" >> $lu_f
	echo "      ${unique_id}_sensor_age:" >> $lu_f
	echo "        friendly_name: \"$name Sensor Age\"" >> $lu_f
#	echo "        entity_id: sensor.time" >> $lu_f
	echo "        value_template: >-" >> $lu_f
	echo "          {% if states.sensor.${unique_id}_temperature.last_changed > states.sensor.${unique_id}_humidity.last_changed %}" >> $lu_f
#	echo "            {{ (states.sensor.time.last_changed - states.sensor.${unique_id}_temperature.last_changed).total_seconds() | round(0) }}" >> $lu_f
	echo "            {{ (now() - states.sensor.${unique_id}_temperature.last_changed).total_seconds() | round(0,default=0) }}" >> $lu_f
	echo "          {% else %}" >> $lu_f
#	echo "            {{ (states.sensor.time.last_changed - states.sensor.${unique_id}_humidity.last_changed).total_seconds() | round(0) }}" >> $lu_f
	echo "            {{ (now() - states.sensor.${unique_id}_humidity.last_changed).total_seconds() | round(0,default=0) }}" >> $lu_f
	echo "          {% endif %}" >> $lu_f
	echo "        unit_of_measurement: \"Seconds\"" >> $lu_f
	echo "" >> $lu_f


	# custom signal sensor counter for watchdog or other stat use

	echo "  - platform: mqtt" >> $sn_f
	echo "    name: \"$name Sensor SNR\"" >> $sn_f
	echo "    unique_id: \"${unique_id}_sensor_snr\"" >> $sn_f
	echo "    device_class: signal_strength" >> $sn_f
	echo "    icon: mdi:signal" >> $sn_f
	echo "    state_topic: \"$topic_base/$id\"" >> $sn_f
	echo "    unit_of_measurement: 'dB'" >> $sn_f
	echo "    value_template: >-" >> $sn_f
	echo "      {{ value_json.snr }}" >> $sn_f
	echo "" >> $sn_f

done

echo ""
echo "Merging generated data into package..."

echo "# Sensor Package File" >> $p_f
echo "" >> $p_f
echo "# Temperature and Humidity Reading Sensors" >> $p_f
echo "sensor:" >> $p_f
cat $s_f >> $p_f
echo "" >> $p_f
echo "" >> $p_f
echo "# Battery Low Warning Sensors" >> $p_f
echo "binary_sensor:" >> $p_f
cat $bs_f >> $p_f

echo "# Sensor Filter Package File" >> $fp_f
echo "" >> $fp_f
echo "sensor:" >> $fp_f
echo "" >> $fp_f
cat $f_f >> $fp_f

echo "# Sensor Last_Updated Package File" >> $lup_f
echo "" >> $lup_f
echo "sensor:" >> $lup_f
echo "" >> $lup_f
cat $lu_f >> $lup_f

echo "# Sensor Signal Package File" >> $snp_f
echo "" >> $snp_f
echo "sensor:" >> $snp_f
echo "" >> $snp_f
cat $sn_f >> $snp_f

echo "Done."
