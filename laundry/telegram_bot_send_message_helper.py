# Filename: telegram_bot_send_message_helper.py
# Place this file in /config/python_scripts/
# 
# Source:
# https://community.home-assistant.io/t/help-how-to-make-a-dynamic-list-of-integers-variable-not-working/
#
# Usage from service call:
# 
#       - service: python_script.telegram
#        data_template:
#          target: "{{ states.variable.list_of_user_ids_to_send_to.state }}"
#          message: The message to send to all of them.
#
# Requires:
# The expected bot is integration named "telegram_bot"

target = data.get('target', '')
message = data.get('message', '')
if target and message:
    if ',' in target:
        targets = [ int(v.strip()) for v in target.split(',') ]
    else:
        targets = [ int(target) ]

    service_data = {
        'target': targets,
        'message': message,
    }

    hass.services.call('telegram_bot', 'send_message', service_data)
