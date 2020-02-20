#!/bin/bash
s_f="output/generated_sensors.yaml"
bs_f="output/generated_binary_sensors.yaml"
p_f="output/generated_combined_package.yaml"
topic_base="homeassistant/sensor/rtl433/Acurite_tower_sensor"

# List of sensors
sensor_list=( "1234/Outside Front" "5678/Outside Rear" "4321/Downstairs Hall" "8765/Upstairs Hall" )


# Indoor sensors spec says -20 to +70C
# Outdoor sensors spec says -40C to +70C
# but most bad high values seem WAY high hundreds
temp_min_C=-20
temp_max_C=100


echo '' > $s_f
echo '' > $bs_f
echo '' > $p_f

echo ""
echo "Sensor filename: $s_f"
echo "Binary Sensor filename: $bs_f"
echo "package filename: $p_f"
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

        # write out data to file
        echo "  # $name Sensor" >> $s_f
        echo "  - platform: mqtt" >> $s_f
        echo "    name: \"$name Temperature\"" >> $s_f
        echo "    unique_id: \"${unique_id}_temperature\"" >> $s_f
        echo "    state_topic: \"$topic_base/$id\"" >> $s_f
        echo "    unit_of_measurement: '°C'" >> $s_f
        echo "    value_template: >-" >> $s_f
        echo "      {% if value_json.temperature_C > $temp_min_C or value_json.temperature_C < $temp_max_C %}" >> $s_f
        echo "        {{ value_json.temperature_C }}" >> $s_f
        echo "      {% else %}" >> $s_f
        echo "        {{ states.sensor.${unique_id}_temperature.state }}" >> $s_f
        echo "      {% endif %}" >> $s_f


        echo "  - platform: mqtt" >> $s_f
        echo "    name: \"$name Humidity\"" >> $s_f
        echo "    unique_id: \"${unique_id}_humidity\"" >> $s_f
        echo "    state_topic: \"$topic_base/$id\"" >> $s_f
        echo "    unit_of_measurement: '%'" >> $s_f
        echo "    value_template: >-" >> $s_f
        echo "      {% if value_json.humidity >= 0 or value_json.humidity <= 100 %}" >> $s_f
        echo "        {{ value_json.humidity }}" >> $s_f
        echo "      {% else %}" >> $s_f
        echo "        {{ states.sensor.${unique_id}_humidity.state }}" >> $s_f
        echo "      {% endif %}" >> $s_f
        echo "" >> $s_f



        echo "  # $name Sensor" >> $bs_f
        echo "  - platform: mqtt" >> $bs_f
        echo "    name: \"$name Sensor Battery Low\"" >> $bs_f
        echo "    unique_id: \"${unique_id}_sensor_battery_low\"" >> $s_f
        echo "    state_topic: \"$topic_base/$id\"" >> $bs_f
        echo "    payload_on: \"1\"" >> $bs_f
        echo "    payload_off: \"0\"" >> $bs_f
        echo "    value_template: >-" >> $bs_f
        echo "      {% if value_json.battery_low == 0 or value_json.battery_low == 1 %}" >> $bs_f
        echo "        {{ value_json.battery_low }}" >> $bs_f
        echo "      {% else %}" >> $bs_f
        echo "        {{ states.sensor.${unique_id}_battery_low.state }}" >> $bs_f
        echo "      {% endif %}" >> $bs_f
        echo "" >> $bs_f

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

echo "Done."
