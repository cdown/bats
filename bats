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
