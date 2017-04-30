#!/bin/bash

ps_path=/sys/class/power_supply

batteries=( "$@" )
if ! (( "${#batteries[@]}" )); then
    batteries=( "$ps_path"/BAT* )
    batteries=( "${batteries[@]#"$ps_path"}" )
fi

statuses=
total_charge_full=0
total_charge_now=0

for batt in "${batteries[@]}"; do
    batt_dir=$ps_path/$batt

    if [[ -e "$batt_dir"/energy_now ]]; then
        prefix=energy
    else
        prefix=charge
    fi

    read -r -n 1 status < "$batt_dir"/status
    statuses+=$status

    read -r charge_full < "$batt_dir"/"$prefix"_full
    read -r charge_now < "$batt_dir"/"$prefix"_now
    total_charge_full+=$charge_full
    total_charge_now+=$charge_now
done

percent=$(( total_charge_now * 100 / total_charge_full ))

printf '%s%s\n' "$percent" "$statuses"
