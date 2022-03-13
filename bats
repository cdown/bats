#!/bin/bash

shopt -s nullglob

power_supply_path=/sys/class/power_supply

sum() {
    local existing
    declare -a existing

    for file do
        [[ -f $file ]] && existing+=( "$file" )
    done
    awk '{ sum += $1 } END { print sum }' "${existing[@]}" < /dev/null
}

get_statuses() {
    grep -ho '^.' "${@/%//status}" </dev/null | paste -sd ''
}

battery_paths=( "${@/#/$power_supply_path/}" )
(( ${#battery_paths[@]} == 0 )) && battery_paths=( "$power_supply_path"/BAT* )

if (( ${#battery_paths[@]} == 0 )); then
    printf 'No batteries found in %s\n' "$power_supply_path" >&2
    exit 2
fi

charge_full=$(sum \
    "${battery_paths[@]/%//energy_full}" \
    "${battery_paths[@]/%//charge_full}"
)
charge_now=$(sum \
    "${battery_paths[@]/%//energy_now}" \
    "${battery_paths[@]/%//charge_now}"
)
status=$(get_statuses "${battery_paths[@]}")

# Avoid dividing by zero if charge_full is nonsense
if (( charge_full <= 0 )); then
    printf 'Your battery max charge value (%s) is <= 0.\n' "$charge_full" >&2
    printf 'Please consider filing a kernel bug for your battery.\n' >&2
    exit 1
fi

charge_percentage=$(( charge_now * 100 / charge_full ))

# Some batteries show values >100 and never "F", or report >100 values :-(
if (( charge_percentage >= 100 )); then
    charge_percentage=100
    status=$(printf "%0.sF" "${battery_paths[@]}")
fi

printf '%d%s\n' "$charge_percentage" "$status"
