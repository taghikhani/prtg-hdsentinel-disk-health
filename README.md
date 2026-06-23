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

# Installation

## 1. Copy Script

Copy `Disk-Health.ps1` to:

C:\Program Files\PRTG Network Monitor\Custom Sensors\EXEXML

or

C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML

Depending on your PRTG installation.

---

## 2. Verify Hard Disk Sentinel XML Service

Open the following URL on the target server:

http://localhost:61220/xml

If the XML page loads successfully, the integration is working correctly.

---

## 3. Add the Sensor in PRTG

1. Open PRTG Web Interface
2. Navigate to the device representing the monitored server
3. Click Add Sensor
4. Search for: EXE/Script Advanced
5. Select: Disk-Health.ps1
6. Click Continue

### Sensor Parameters

In the **Parameters** field enter:

"%host" 61220

PRTG automatically replaces `%host` with the IP address configured on the device.

Example:

If the device IP is:

192.168.1.100

PRTG will execute:

Disk-Health.ps1 "192.168.1.100" 61220
---

## Using the Device IP Automatically

In the sensor settings, configure the Parameters field as:

%host 61220

### Example

If the PRTG device IP is:

192.168.1.100

PRTG automatically executes:

Disk-Health.ps1 192.168.1.100 61220

This allows the same sensor template to be reused across multiple servers without modifying the script.

---

## Running the Sensor on the Target Host (Recommended)

For best results:

- Install Hard Disk Sentinel on the monitored server.
- Install a PRTG Remote Probe on the same server.
- Run the sensor through the local probe.

Use:

-ServerIP 127.0.0.1 -Port 61220

This avoids firewall issues and ensures direct access to the local Hard Disk Sentinel service.

---

## Hard Disk Sentinel Integration

Open:

Configuration → Integration → Web Status

Enable:

- Enable Web Status
- Enable XML Status Page

Default URL:

http://localhost:61220/xml

Verify the URL returns XML before adding the sensor to PRTG.

---

## Generated Channels

- Health
- Predictive Failure Status
- Percent Endurance Used
- Controller Timeouts
- Uncorrectable Errors Status
- Media and Data Integrity Errors

---

## Troubleshooting

### HTTP Request Failed

Verify:

http://<server-ip>:61220/xml

is reachable from the PRTG Probe server.

### No Channels Created

Verify:

- Hard Disk Sentinel is running
- Web Status service is enabled
- XML Status page is enabled
- The configured IP and port are correct

### Access Denied

Run:

Set-ExecutionPolicy RemoteSigned

from an elevated PowerShell console.

---

## License

MIT License
