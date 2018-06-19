enum Ensure
{
    Absent
    Present
}

[DscResource()]
class LifecycleDsc
{
    [DscProperty(Key)]
    [string]$LifecycleState

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Mandatory)]
    [string] $LifecyclePath

    <#
        This method is equivalent of the Get-TargetResource script function.
        The implementation should use the keys to find appropriate resources.
        This method returns an instance of this class with the updated key
         properties.
    #>
    [LifecycleDsc] Get()
    {

        $Item = Test-Path $This.LifecyclePath
 
        if ($Item -eq $True)
        {
            $This.Ensure = [Ensure]::Present
        }
        else
        {
            $This.Ensure = [Ensure]::Absent
        }
 
        Return $This
    }

    <#
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] Set()
    {
        $Item = Test-Path $This.LifecyclePath
        if ($This.Ensure -eq [Ensure]::Present)
        {
            if (-not $Item)
            {
                Write-Verbose -Message "Folder not found, creating Folder"
                New-Item -ItemType Directory -Path $This.Path
            }
        }
        Else
        {
            if ($Item)
            {
                Write-Verbose -Message "File exists and should be absent.  Deleting file"
                Remove-Item -Path $This.Path
            }
        }
    }
 
    <#
        This method is equivalent of the Test-TargetResource script function.
        It should return True or False, showing whether the resource
        is in a desired state.
    #>
    [bool] Test()
    {
        $Item = Test-Path $This.LifecyclePath
 
        if ($This.Ensure -eq [Ensure]::Present)
        {
            Return $Item
        }
        else
        {
            Return -not $Item
        }
    }
}