<#
.SYNOPSIS
    Reset-Module unloads a specified module the current session and re-imports it.

.DESCRIPTION
    The Reset-Module function removes a specified module from the current session's memory
    and then re-imports it back into the session in the Global scope.

    If the module was originally loaded into memory via a PowerShell Manifest file,
    Reset-Module will attempt to load the module via its Manifest file before falling back
    to a module file.

.PARAMETER Name
    Specifies the name of a module to remove and re-import.

.PARAMETER Passthru
    Passes an object that represents the item to the pipeline. By default, this cmdlet does not generate any output.

.EXAMPLE
    PS> Reset-Module -Name powerShellUtils

    <By default, this command produces no output>

.EXAMPLE
    PS> "moduleOne","moduleTwo" | Reset-Module -Passthru


    ModuleType Version    Name                                ExportedCommands
    ---------- -------    ----                                ----------------
    Script     0.1        moduleOne                           functionOne
    Script     1.0        moduleTwo                           functionTwo

.EXAMPLE
    PS> Get-Module moduleOne | Reset-Module

    <By default, this command produces no output>

#>
function Reset-Module {
    [CmdletBinding()]
    param()

    DynamicParam {

        #Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        #region Name parameter

        #Set the dynamic parameter name
        $ParameterName_Name = 'Name'

        #Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        #Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 0
        $ParameterAttribute.ValueFromPipeline = $true

        #Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        #Generate and set the ValidateSet
        $arrSet = Get-Module | Select-Object -ExpandProperty Name
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        #Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        #Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName_Name, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName_Name, $RuntimeParameter)

        #endregion

        #region Passthru parameter

        #Create the Passthru parameter as a dynamic parameter, even though its really a static parameter
        #This allows for correctly-positioned parameters.

        #Set the dynamic parameter name
        $ParameterName_Passthru = 'Passthru'

        #Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        #Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1

        #Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        #Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName_Passthru, [switch], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName_Passthru, $RuntimeParameter)

        #endregion

        return $RuntimeParameterDictionary

    }

    Begin {
    }

    Process {
        #Convert the dynamic parameters to more friendly variables.
        $Name     = $PsBoundParameters[$ParameterName_Name]
        $Passthru = $PsBoundParameters[$ParameterName_Passthru]

        if (-not $Name) { return }

        Try {
            Write-Verbose "Removing module '$Name' from the current session..."
            $mod = Get-Module -Name $Name -ErrorAction Stop | Select-Object *
            Remove-Module -Name $mod.Name -ErrorAction Stop -Verbose:$false
        }
        Catch {
            throw
        }

        Try {
            #Try to import the module as a psd1 file.
            Import-Module -Name $mod.Path.Replace(".psm1",".psd1") -Global -ErrorAction Stop -Verbose:$false
            Write-Verbose "Imported module '$($mod.Name)' into the current session."
        }
        Catch {
            Try {
                #If importing the module as a psd1 fails, try psm1.
                Import-Module -Name $mod.Path -Global -ErrorAction Stop -Verbose:$false
                Write-Verbose "Imported module '$($mod.Name)' into the current session."
            }
            Catch {
                throw
            }
        }

        if ($Passthru) {
            Get-Module $Name -Verbose:$false
        }
    }

    End {

    }
}

New-Alias -Name rsm -Value Reset-Module -ErrorAction SilentlyContinue