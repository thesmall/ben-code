function Start-KasaPartyMode {
<#
    .SYNOPSIS
        Starts party-mode on a color-capable TP-Link Kasa lightbulb. "Party-Mode" emulates a strobe effect by transitioning the lightbulb's color (with variable rapidity).

    .DESCRIPTION
        TP-Link Kasa color-capable Smart Lightbulbs do not have a native "party-mode" or "disco-mode" effect, where the lightbulb (typically rapidly) changes between random colors.

        Start-KasaPartyMode achieves this effect by looping for a specified period of time, changing the color of the lightbulb randomly, with user-specified cycle speed and color-transition values.

        Party-mode can be cancelled prematurely by pressing any keyboard key.
        
        Requirements:
            * pip - The python package installer is a most typical means for installing python packages. This function relies on pip to validate that python-kasa is installed.
            * python-kasa - This library performs all of the heavy lifting and is required to perform any action against a TP-Link Kasa lightbulb. 
            * PowerShell 7.x - This code has only been tested on PowerShell 7.x systems.

        :Seizure Warning:
        A VERY SMALL PERCENTAGE OF PEOPLE EXPERIENCE EPILEPTIC SEIZURES WHEN EXPOSED TO CERTAIN LIGHT PATTERNS OR FLASHING LIGHTS.
        EXPOSURE TO THESE PATTERNS MAY INDUCE AN EPILEPTIC SEIZURE IN THESE INDIVIDUALS.
        IF YOU, OR ANYONE IN YOUR FAMILY, HAVE AN EPILEPTIC CONDITION, CONSULT YOUR PHYSICIAN PRIOR TO USING THIS TOOl.
        IF YOU EXPERIENCE DIZZINESS, ALTERED VISION, EYE OR MUSCLE TWITCHES, LOSS OF AWARENESS, DISORIENTATION, ANY INVOLUNTARY MOVEMENT, OR CONVULSIONS WHILE USING THIS TOOL, IMMEDIATELY DISCONTINUE USE AND CONSULT YOUR PHYSICIAN.

    .EXAMPLE
        PS> Start-KasaPartyMode -DeviceAlias "Office Lamp" -CycleSpeed 0 -TimeLimitMinutes 5 -Transition 0 -ResetOnCompletion

        Runs party-mode for the "Office Lamp" lightbulb for 5 minutes, cycling from color to color with no delay or transition.
        Once party-mode has concluded, the lightbulb color will change back to whatever color it was prior to party-mode being initiated.
        
        This command does not produce any output.

    .NOTES
        Author: Ben Small
        DateCreated: 2023-10-07
        Links:
        * https://github.com/python-kasa/python-kasa
#>
    [CmdletBinding(
        DefaultParameterSetName = 'byDeviceAlias'
    )]
    param(
        #Specifies the alias of a smart bulb device, as defined inthe Kasa app.
        [Parameter(
            ParameterSetName = 'byDeviceAlias'
        )]
        [String] $DeviceAlias,

        #Specifies the IP address of a smart bulb device.
        [Parameter(
            ParameterSetName = 'byDeviceIP'
        )]
        [String] $DeviceIP,

        #Specifies how long the "party-mode" effect should run for. By default, party-mode will run for 5 minutes.
        [Int] $TimeLimitMinutes = 5,

        #Specifies the period of time any given color is displayed before cycling to the next random color. By default, the cycle speed will be 0.5 seconds.
        [Int] $CycleSpeed = 0.5,

        #Specifies the transition time, in miliseconds, between colors. By default, the transition time will be 1000 miliseconds (1 second).
        #A low transition time (< 100ms) will make the color-to-color transition seem abrupt, while a high transition time (> 1000ms) will make the color-to-color effect seem smooth.
        [Int] $Transition = 1000,

        #Specifies if the bulb's color should return to the color it was set too prior to starting the "party-mode" effect.
        [Switch] $ResetOnCompletion
    )

    begin {

    }
    
    process {
        #region Test for python-kasa

        #python-kasa needs to be installed. The way this is validated is by assuming it's been installed via pip.

        $pythonKasa = pip show python-kasa

        if (-not (($pythonKasa) -and ($pythonKasa -like "*Python API for TP-Link Kasa Smarthome devices*"))) {
            Write-Warning "python-kasa is not installed. Install it by running 'sudo pip install python-kasa'."
            return
        }

        #endregion

        #region Convert Device Alias to IP
        
        #There is a significant delay associated with the "kasa discover" process (which occurs when specifying a device by its --alias), 
        # and so it is preferable to invoke commands against a device using its IP address.
        #To do this, iterate over all devices to derive the device's IP from its alias. Stop when we find a device alias == the supplied alias.
        #We also use this opportunity to abort processing if the supplied device is not a smart bulb, or is not capable of changing colors.

        if ($PSCmdlet.ParameterSetName -eq "byDeviceAlias") {
            $kasahash = kasa --json | ConvertFrom-Json -AsHashtable

            foreach ($k in $kasahash.GetEnumerator()) {
                if ($k.Value.system.get_sysinfo.alias -eq $DeviceAlias) {
                    $DeviceIP = $k.Name
                    
                    Write-Verbose "Matched Device Alias: '$DeviceAlias' to Host: '$DeviceIP'"

                    if ($k.Value.system.get_sysinfo.mic_type -eq "IOT.SMARTBULB" -and $k.Value.system.get_sysinfo.is_color -eq 1) {
                        break
                    }
                    else {
                        Write-Warning "Device: $DeviceAlias is not a color-capable lightbulb. Aborting."
                        return
                    }
                }
            }
        }

        #endregion

        #region Capture the Current HSV

        #This logic captures the current HSV: Hue, Saturation, Value (Brightness) so that the bulb can be reset to its original HSV when "party-mode" has concluded.
        #It does not work if the loop is ended early by keypress.

        if ($ResetOnCompletion) {
            $currentHSV = kasa --host $DeviceIP --type bulb hsv

            [String[]] $hsv = $($currentHSV -split "\(" -replace "\)",'' | Select-Object -Skip 1 -First 1) -split ", "
            
            $originalHSV = $hsv -replace "hue=",'' -replace "saturation=",'' -replace "value=",'' -join " "

            Write-Verbose "Original HSV: $originalHSV"
        }

        #endregion

        #region Party Mode Loop

        #Loop until the stopwatch elapsed time is greater than TimeLimitMinutes, or any key is pressed.

        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

        Write-Host "Press any key to end early..."

        do {
            $hue = $(Get-Random -Minimum 0 -Maximum 255) 
            
            kasa --host $DeviceIP --type bulb hsv $hue 100 100 --transition $Transition | Out-Null

            Start-Sleep -Seconds $CycleSpeed
        }
        until (($stopWatch.Elapsed.TotalMinutes -gt $TimeLimitMinutes) -or ([System.Console]::KeyAvailable))

        $stopWatch.Stop()

        #endregion

        #region Change Back to the Original HSV

        if ($ResetOnCompletion) {
            [int] $h = $($originalHSV -split " ")[0]
            [int] $s = $($originalHSV -split " ")[1]
            [int] $v = $($originalHSV -split " ")[2]

            kasa --host $DeviceIP --type bulb hsv $h $s $v | Out-Null

            Write-Verbose "Reset to original HSV: $originalHSV."
        }

        #endregion
    }

    end {

    }
}