# PRTG Hard Disk Sentinel Integration

**Advanced PRTG EXE/Script Advanced sensor for monitoring Hard Disk Sentinel health and SMART attributes.**

![PRTG](https://img.shields.io/badge/PRTG-Network%20Monitor-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Hard Disk Sentinel](https://img.shields.io/badge/Hard%20Disk%20Sentinel-Professional%2FEnterprise-orange)

## Features

- Real-time HDD and SSD health monitoring
- SSD endurance / wear-out monitoring
- Predictive Failure detection (HP Smart Array)
- Controller timeout tracking
- Uncorrectable error and media integrity error monitoring
- Automatic HDD/SSD detection
- Full multi-disk support
- Clean native PRTG XML output with proper limits and messages

## Requirements

- PRTG Network Monitor
- Hard Disk Sentinel **Professional** or **Enterprise** (with WebStatus enabled)
- PowerShell 5.1 or newer
- Network access from PRTG Probe to Hard Disk Sentinel's HTTP port

## Installation

### 1. Copy the Script

Copy `Disk-Health.ps1` to one of the following directories on your **PRTG Probe** server:

```text
C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\
C:\Program Files\PRTG Network Monitor\Custom Sensors\EXEXML\
```

### 2. Configure Hard Disk Sentinel

1. Open **Hard Disk Sentinel** on the monitored server.
2. Go to **Options** → **Advanced Options** → **Integration**.
3. Enable **Web Status**.
4. Set the desired **HTTP Port** (default: `61220`).
5. (Optional) Set a password if needed.
6. Click **OK** to apply.

**Verify the XML service is working:**

Open in a browser:
```
http://localhost:61220/xml
```
(or replace `localhost` with the actual server IP). You should see a detailed XML document containing disk information.

### 3. Add Sensor in PRTG

1. In the PRTG Web Interface, go to the device representing the monitored server.
2. Click **Add Sensor**.
3. Search for and select **EXE/Script Advanced**.
4. Choose `Disk-Health.ps1` from the dropdown.
5. In the **Parameters** field, enter:

   ```
   "%host" 61220
   ```

   - "`%host`" will be automatically replaced by the device's IP address.
   - Change `61220` if you use a different port in Hard Disk Sentinel.

6. Click **Continue** and save the sensor.

**Recommended Setup**: Install a **PRTG Remote Probe** on the target server and run the sensor locally for best performance and reliability.

## Sensor Channels

The sensor automatically creates the following channels for each detected disk:

- **Disk X [Serial] Health** — Overall health percentage
- **Disk X [Serial] Predictive Failure Status** — HP Smart Array predictive failures
- **Disk X [Serial] Percent Endurance Used** — SSD wear level (SSD only)
- **Disk X [Serial] Controller Timeouts** — Communication timeouts
- **Disk X [Serial] Uncorrectable Errors Status** — Uncorrectable error count
- **Disk X [Serial] Media and Data Integrity Errors** — Media errors

## Parameters

| Parameter     | Default     | Description                          |
|---------------|-------------|--------------------------------------|
| `ServerIP`    | `127.0.0.1` | IP address of the Hard Disk Sentinel server |
| `Port`        | `61220`     | HTTP port of the WebStatus service   |

## Troubleshooting

| Issue                          | Possible Solution |
|--------------------------------|-------------------|
| **HTTP Request Failed**        | Verify the XML URL (`http://IP:61220/xml`) is reachable from the PRTG Probe. |
| **No channels appear**         | Ensure Web Status and XML output are enabled in Hard Disk Sentinel. |
| **Access Denied**              | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in an elevated PowerShell. |
| **Sensor timeout**             | Increase timeout in sensor settings (recommended: 60–90 seconds). |
| **Password protected**         | Add password support to the script if needed (advanced). |

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests and issues are welcome!

---

Made with ❤️ for the sysadmin and monitoring community.
