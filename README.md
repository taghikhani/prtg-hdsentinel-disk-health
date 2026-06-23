# PRTG Hard Disk Sentinel Disk Health Sensor

PRTG EXE/Script Advanced sensor for monitoring Hard Disk Sentinel health and SMART attributes.

## Features

- HDD and SSD health monitoring
- SSD endurance monitoring
- Predictive failure detection
- Controller timeout monitoring
- Media and Data Integrity Error monitoring
- Multi-disk support
- Native PRTG XML output

## Requirements

- PRTG Network Monitor
- Hard Disk Sentinel Professional or Enterprise
- PowerShell 5.1 or newer

## Installation

Copy `Disk-Health.ps1` to:

`Custom Sensors\EXEXML`

Create an **EXE/Script Advanced** sensor and select the script.

## Hard Disk Sentinel Integration

Open:

Configuration → Integration → Web Status

Enable:

- Enable Web Status
- Enable XML Status Page

Default URL:

http://localhost:61220/xml

Verify the URL returns XML before adding the sensor to PRTG.

## Parameters

- ServerIP (default: 127.0.0.1)
- Port (default: 61220)

Example:

Disk-Health.ps1 -ServerIP 192.168.1.10 -Port 61220

## Generated Channels

- Health
- Predictive Failure Status
- Percent Endurance Used
- Controller Timeouts
- Uncorrectable Errors Status
- Media and Data Integrity Errors

## Notes

For the `Uncorrectable Errors Status` channel, a value of **100 indicates healthy status**. Values below 100 are treated as degraded according to Hard Disk Sentinel reporting.

## License

MIT
