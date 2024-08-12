$object = [pscustomobject]@{
    FirstName = 'Bob'
    LastName = 'Smith'
    City = 'San Diego'
    State = 'CA'
    Phone = '555-5555'
    Gender = 'Male'
    Occupation = 'System Administrator'
    DOB = '02/21/1970'
}

#Give this object a unique typename
$object.PSObject.TypeNames.Insert(0,'User.Information')

#Configure a default display set
$defaultDisplaySet = 'FirstName','LastName','Gender','City'

#Create the default property display set
$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)

$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

$object | Add-Member MemberSet PSStandardMembers $PSStandardMembers