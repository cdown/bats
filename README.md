bats is an extremely simple battery status printer written in pure POSIX shell.
It uses [sysfs][sysfs] to get the battery data, so right now it is
Linux-specific.

## Usage

    $ # Will pick the first available battery, useful if you only have one
    $ bats
    42D
    $ # Explicitly choose a battery
    $ bats BAT1
    76C

## Output

The output is in the following format `<percentage><status>`. The percentage is
the remaining battery charge left, as calculated when comparing the full
(design) charge to the current charge.

### Status symbols:

The status symbols transparently represent the battery status as provided by
`battery.h`:

- C: Charging
- D: Discharging
- F: Full
- U: Unknown

[sysfs]: https://www.kernel.org/doc/Documentation/filesystems/sysfs.txt
