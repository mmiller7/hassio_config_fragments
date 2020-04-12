
#!/bin/bash

# Put the IP address (recommended) or hostname of your MQTT broker
broker="192.168.1.X"
# Set the authentication information for your MQTT broker
username="your_mqtt_username_here"
password="your_mqtt_username_here"

# This topic may be changed, but must match what the YAML is looking for
topic="homeassistant/sensor/speedtest-net"

# This is the command that is run to do the test.  You may optionally add "--server-id=12345" as shown
# message="`/config/speedtest-net/speedtest --accept-license --server-id=12345 --format=json`"
# but you will need to figure out the correct server-ID by "running /config/speedtest-cli/speedtest --servers"
# in a terminal to see a list of nearby speedtest-servers.  If you do not specify, it will choose automatically
message="`/config/speedtest-net/speedtest --accept-license --format=json`"


# This is a hack job copying files because they are apparently missing from the main hassio container
export LD_LIBRARY_PATH='/config/speedtest-net/mosquitto_deps/lib'
/config/speedtest-net/mosquitto_deps/mosquitto_pub -h "$broker" -u "$username" -P "$password" -t "$topic" -m "$message"
