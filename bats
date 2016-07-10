#!/bin/sh

first_battery() {
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

charge_prefix() {
    # Return the prefix to use when addressing the charge files in sysfs.
    #
    # Depending on your battery module, and whether your ACPI firmware is iffy,
    # you might get energy_* (watts), or charge_* (amps). Since we only report
    # the percentage, we don't mind which one we get, but this does mean that
    # we end up having to look for both to work out the files we should look
    # at.

    local battery_path="$1"

    if [ -f "$battery_path/charge_now" ]; then
        echo charge
    else
        echo energy
    fi
}

power_supply_path=/sys/class/power_supply
battery=${1-$(first_battery "$power_supply_path")}
battery_path=$power_supply_path/$battery

if ! [ -d "$battery_path" ]; then
    printf 'Battery path does not exist: %s\n' "$battery_path" >&2
    exit 1
fi

prefix=$(charge_prefix "$battery_path")

read -r charge_now < "$battery_path/$prefix"_now
read -r charge_full < "$battery_path/$prefix"_full_design
read -r status < "$battery_path/status"

if [ "$charge_full" -eq 0 ]; then
    charge_percentage=0
else
    charge_percentage=$(( charge_now * 100 / charge_full ))
fi

if [ "$charge_percentage" -ge 100 ]; then
    charge_percentage=100
    status=F  # Some batteries seem to show values >100 and never "F"
fi

printf '%d%.1s\n' "$charge_percentage" "$status"
