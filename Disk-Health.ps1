param(
    [string]$ServerIP = "127.0.0.1", 
    [int]$Port = 61220               
)

# Fetch XML data from Hard Disk Sentinel API
$result = Invoke-WebRequest -Uri "http://$($ServerIP):$($Port)/xml" -ErrorAction SilentlyContinue -UseBasicParsing

if ($result.StatusCode -ne 200){
    write-host ""
    write-host "1"
    write-host "HTTP Request Failed"
    write-host ""
    Exit
}

[xml] $xdoc = $result.Content

Write-Output "<?xml version=`"1.0`" encoding=`"Windows-1252`" ?>"
Write-Output "<prtg>"

foreach ($diskNode in $xdoc.Hard_Disk_Sentinel.Childnodes) {
    if ($diskNode.Name.StartsWith("Physical_Disk_Information_Disk_")) {
        
        # Extract summary block
        $summary = $diskNode.Hard_Disk_Summary
        $health = $summary.Health
        $index = $summary.Hard_Disk_Number
        $serial = $summary.Hard_Disk_Serial_Number
        $name = $summary.Hard_Disk_Model_ID
        
        # Validation filter: Skip empty or dead nodes
        if ($null -eq $health -or $null -eq $serial -or $serial -contains "?" -or $serial.Trim() -eq "") {
            continue
        }
        
        $health = ($health -replace "[%]","").Trim()
        $index = $index.Trim()
        $serial = $serial.Trim()
        $name = $name.Trim()

        # Identify hardware medium type (Precise Check)
        $isSSD = $true
        $rotationRate = $diskNode.ATA_Features.Nominal_Media_Rotation_Rate
        
        if ($null -ne $rotationRate -and $rotationRate -notlike "*SSD*" -and $rotationRate -match '\d+' -and [int]$Matches[0] -gt 0) {
            $isSSD = $false
        }
        elseif ($name -like "*WDC*" -and $name -notlike "*SSD*" -and $name -notlike "*NVMe*") {
            $isSSD = $false
        }

        # 1. Disk Health Channel Configuration
        Write-Output "<result>"
        Write-Output "  <unit>Percent</unit>"
        Write-Output "  <LimitMode>1</LimitMode>"
        if ($isSSD) {
            Write-Output "  <LimitMinError>6</LimitMinError>"
            Write-Output "  <LimitMinWarning>10</LimitMinWarning>"
        } else {
            Write-Output "  <LimitMinError>100</LimitMinError>" # دیسک‌های HDD با سلامت زیر ۱۰۰ خطا می‌شوند
        }
        Write-Output "  <LimitErrorMsg>Disk $index Health Critical</LimitErrorMsg>"
        Write-Output "  <LimitWarningMsg>Disk $index Health Warning</LimitWarningMsg>"
        Write-Output "  <channel>Disk $index $serial Health</channel>"
        Write-Output "  <value>$health</value>"
        Write-Output "</result>"

        # Parse S.M.A.R.T. section from OuterXml
        $diskOuterXml = $diskNode.OuterXml

        # 2. HP Smart Array - Predictive Failure Errors
        if ($diskOuterXml -match '<Attribute[^>]*Name="Predictive Failure Errors"[^>]*Value="(\d+)"[^>]*>') {
            $predFailure = $Matches[1].Trim()
            Write-Output "<result>"
            Write-Output "  <unit>Count</unit>"
            Write-Output "  <LimitMode>1</LimitMode>"
            Write-Output "  <LimitMaxError>0</LimitMaxError>"
            Write-Output "  <LimitErrorMsg>Disk $index Smart Array Hardware Predictive Failure Alert</LimitErrorMsg>"
            Write-Output "  <channel>Disk $index $serial Predictive Failure Status</channel>"
            Write-Output "  <value>$predFailure</value>"
            Write-Output "</result>"
        }

        # 3. HP Smart Array - SSD Percent Endurance Used (Only outputs for SSD drives)
        if ($isSSD -and ($diskOuterXml -match '<Attribute[^>]*Name="Percent Endurance Used"[^>]*Value="(\d+)"[^>]*>')) {
            $enduranceUsed = $Matches[1].Trim()
            Write-Output "<result>"
            Write-Output "  <unit>Percent</unit>"
            Write-Output "  <LimitMode>1</LimitMode>"
            Write-Output "  <LimitMaxWarning>80</LimitMaxWarning>"
            Write-Output "  <LimitMaxError>90</LimitMaxError>"
            Write-Output "  <LimitWarningMsg>Disk $index SSD Wearout High Warning</LimitWarningMsg>"
            Write-Output "  <LimitErrorMsg>Disk $index SSD Wearout Critical</LimitErrorMsg>"
            Write-Output "  <channel>Disk $index $serial Percent Endurance Used</channel>"
            Write-Output "  <value>$enduranceUsed</value>"
            Write-Output "</result>"
        }

        # 4. HP Smart Array - Other Time Outs (Crucial for tracking drive drops/delays)
        if ($diskOuterXml -match '<Attribute[^>]*Name="Other Time Outs"[^>]*Value="(\d+)"[^>]*>') {
            $timeouts = $Matches[1].Trim()
            Write-Output "<result>"
            Write-Output "  <unit>Count</unit>"
            Write-Output "  <LimitMode>1</LimitMode>"
            Write-Output "  <LimitMaxWarning>50</LimitMaxWarning>"
            Write-Output "  <LimitMaxError>200</LimitMaxError>"
            Write-Output "  <LimitWarningMsg>Disk $index high timeout count warning</LimitWarningMsg>"
            Write-Output "  <LimitErrorMsg>Disk $index critical timeout count error</LimitErrorMsg>"
            Write-Output "  <channel>Disk $index $serial Controller Timeouts</channel>"
            Write-Output "  <value>$timeouts</value>"
            Write-Output "</result>"
        }

        # 5. Legacy - Uncorrectable Error Count Channel Configuration
        if ($diskOuterXml -match '<Attribute[^>]*Name="Uncorrectable Error Count"[^>]*Value="(\d+)"[^>]*>') {
            $uncorrectableValue = $Matches[1].Trim()
            Write-Output "<result>"
            Write-Output "  <unit>Percent</unit>"
            Write-Output "  <LimitMode>1</LimitMode>"
            Write-Output "  <LimitMinError>100</LimitMinError>"
            Write-Output "  <LimitErrorMsg>Disk $index Uncorrectable Error</LimitErrorMsg>"
            Write-Output "  <channel>Disk $index $serial Uncorrectable Errors Status</channel>"
            Write-Output "  <value>$uncorrectableValue</value>"
            Write-Output "</result>"
        }

        # 6. Legacy - Media and Data Integrity Errors Channel Configuration
        if ($diskOuterXml -match '<Attribute[^>]*Name="Media and Data Integrity Errors"[^>]*Value="(\d+)"[^>]*>') {
            $mediaErrorCount = $Matches[1].Trim()
            Write-Output "<result>"
            Write-Output "  <unit>Count</unit>"
            Write-Output "  <LimitMode>1</LimitMode>"
            Write-Output "  <LimitMaxWarning>1</LimitMaxWarning>"
            Write-Output "  <LimitMaxError>1</LimitMaxError>"
            Write-Output "  <LimitWarningMsg>Disk $index Media Warning</LimitWarningMsg>"
            Write-Output "  <LimitErrorMsg>Disk $index Media Critical</LimitErrorMsg>"
            Write-Output "  <channel>Disk $index $serial Media and Data Integrity Errors</channel>"
            Write-Output "  <value>$mediaErrorCount</value>"
            Write-Output "</result>"
        }
    }
}

Write-Output "</prtg>"