#!/bin/bash

sketchybar --add item calendar right \
           --set calendar update_freq=30 \
	   		  icon.font.style=Bold \
                          padding_right=-8 \
                          script="$CONFIG_DIR/plugins/clock.sh"
