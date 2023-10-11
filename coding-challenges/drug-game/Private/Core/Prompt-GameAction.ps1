function Prompt-GameAction {
    [CmdletBinding()]
    param(
        [ValidateSet('Restart', 'Quit')]
        [String] $GameAction
    )

    Write-Debug "IN: Prompt-GameAction"

    $yes      = [System.Management.Automation.Host.ChoiceDescription] "&Yes"
    $no       = [System.Management.Automation.Host.ChoiceDescription] "&No"

    $options = [System.Management.Automation.Host.ChoiceDescription[]](
        $yes,
        $no
    )

    $host.ui.PromptForChoice('Decide:', "Are you sure you want to $($GameAction.ToLower())?", $options, 0)
}