You will also need to copy/download the following files:

1) build the folder structure:
/config/speedtest-net
/config/speedtest-net/mosquitto_pub
/config/speedtest-net/mosquitto_pub/lib

2) The official Speedtest.net CLI application (Linux).  You will want to extract these on hassio under /config/speedtest-net
https://www.speedtest.net/apps/cli
You should end up with the following files:
/config/speedtest-net/speedtest
/config/speedtest-net/speedtest.5
/config/speedtest-net/speedtest.md

3) Copy the MQTT files that are out of scope of HassOS main system using SSH addon
cp  /usr/bin/mosquitto_pub   /config/speedtest-net/mosquitto_pub
cp  /usr/lib/libmosquitto.so*   /config/speedtest-net/mosquitto_pub/lib/
cp  /usr/lib/libcares.so*   /config/speedtest-net/mosquitto_pub/lib/

4) Download the mqtt_pub.sh file from this repository and save it in your config area
/config/speedtest-net/mqtt_pub.sh
Then edit the file to put in your broker, username, password, and optionally add a server-ID

5) Download the YAML config and save it in your packages folder (or add it to your config.yaml)
   Remember - you will need to restart Home Assistant to import the new sensors!

6) Create a "Markdown" Lovelace card to add a speedtest image to your Overview
Example:
      type: markdown
      content: <img src="https://www.speedtest.net/result/c/{{states.sensor.speedtest_net_result_id.state }}.png">
      refresh_interval: 60
 
