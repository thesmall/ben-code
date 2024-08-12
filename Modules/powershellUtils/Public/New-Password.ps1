function New-Password {
<#
    Not Working: System.Web.Security is not present on the system.
#>
    param(
        #Specifies an integer; the length of the password. The minimum length is 12. The maximum length is 128.
        [ValidateRange(12,128)]
        [Int] $Length,

        #Specifies the minimum number of non-alphanumeric characters present in the password. This number cannot exceed the password's length.
        [Int] $NumberOfNonAlphanumericCharacters
    )

    if ($NumberOfNonAlphanumericCharacters -gt $Length) {
        Write-Error -Message "The number of non-alphanumeric characters cannot exceed the length of the password." -Category InvalidArgument
        return
    }

    [pscustomobject] @{
        Password = $([System.Web.Security.Membership]::GeneratePassword($Length, $NumberOfNonAlphanumericCharacters))
        Length   = $Length
        MinimumNumberOfNonAlphanumericCharacters = $NumberOfNonAlphanumericCharacters
    }
}