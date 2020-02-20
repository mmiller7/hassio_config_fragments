#!/bin/bash
name=$1
echo "Generating new esphome s31 device file: s31_$name.yaml"
sed "s/s31_template/s31_$name/g" s31_template.yaml > ../esphome/s31_$name.yaml
echo "Done"
