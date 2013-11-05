#!/bin/sh

get_first_battery() {
    local battery
    local power_supply_path="$1"

    for battery in "$power_supply_path"/*; do
        battery=${battery##*/}
        if [ "$battery" != AC ]; then
            printf '%s' "$battery"
            break
        fi
    done
}

power_supply_path=/sys/class/power_supply
battery=${1-$(get_first_battery "$power_supply_path")}
battery_path=$power_supply_path/$battery

if ! [ -d "$battery_path" ]; then
    printf 'Battery path does not exist: %s\n' "$battery_path" >&2
    exit 1
fi
