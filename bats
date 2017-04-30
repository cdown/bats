#!/bin/bash

set -eu
set -o pipefail
shopt -s nullglob

ps_path=/sys/class/power_supply

batteries=( "$@" )
if ! (( "${#batteries[@]}" )); then
    batteries=( "$ps_path"/BAT* )
    batteries=( "${batteries[@]#"$ps_path"}" )
fi

if ! (( "${#batteries[@]}" )); then
    printf '%s\n' 'No batteries detected' >&2
    exit 2
fi

statuses=
total_charge_full=0
total_charge_now=0

for batt in "${batteries[@]}"; do
    batt_dir=$ps_path/$batt

    if ! [[ -d "$batt_dir" ]]; then
        printf 'Battery directory "%s" does not exist\n' "$batt_dir"
        exit 3
    fi

    [[ -e "$batt_dir"/energy_now ]] && prefix=energy || prefix=charge

    read -r charge_full < "$batt_dir"/"$prefix"_full
    read -r charge_now < "$batt_dir"/"$prefix"_now

    # Some batteries talk nonsense, which might really skew the overall
    # percentage. Limit the damage.
    if (( charge_now > charge_full )); then
        printf 'Current charge %s > reported max charge %s, clamping\n' \
            "$charge_now" "$charge_full" >&2
        charge_now="$charge_full"
    fi

    total_charge_full+=$charge_full
    total_charge_now+=$charge_now

    read -r -n 1 status < "$batt_dir"/status
    statuses+=$status
done

percent=$(( total_charge_now * 100 / total_charge_full ))

printf '%s%s\n' "$percent" "$statuses"
