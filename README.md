bats is an extremely simple battery status printer written in bash. It uses
[sysfs][sysfs] to get the battery data, so right now it is Linux-specific.

## Usage

    $ # Will show information about all available batteries
    $ bats
    42DFF
    $ # Explicitly choose a battery
    $ bats BAT1
    76C

## Output

The output is in the following format `<percentage><status>`. The percentage is
the remaining battery charge left, which is calculated by totalling all of the
battery capacities together and getting a percentage compared to the current
charge.

### Status symbols:

The status symbols transparently represent the battery status as provided by
`battery.h`:

- C: Charging
- D: Discharging
- F: Full
- U: Unknown

[sysfs]: https://www.kernel.org/doc/Documentation/filesystems/sysfs.txt
