enum Ensure
{
    Absent
    Present
}

[DscResource()]
class Lifecycle
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
    [Lifecycle] Get()
    {
        $logmanquery = (lifecycle.exe get $this.LifecycleState | Select-String -Pattern Name) -replace 'Name:                 ', ''

        if ($logmanquery -contains $this.LifecycleState) 
        {
            $this.Ensure = $true
        }
        else 
        {
            $this.Ensure = $false
        }

        $returnValue = @{
            DataCollectorSetName = $this.LifecycleState
            Ensure               = $this.Ensure
            XmlTemplatePath      = $this.LifecyclePath
        }

        return $returnValue
    }

    <#
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] Set()
    {
        if ( $this.Ensure -eq 'Present' )
        {
            if (Test-Path -Path $this.LifecyclePath) 
            {
                Write-Verbose -Message "Importing logman Data Collector Set $($this.LifecycleState) from Xml template $($this.LifecyclePath)"

                $null = logman.exe import -n $this.LifecycleState -xml $this.LifecyclePath
            } 
            else 
            {
                Write-Verbose -Message "$($this.LifecyclePath) not found or temporary inaccessible, trying again on next consistency check"
            }
        }
        elseif ( $this.Ensure -eq 'Absent' ) 
        {
            Write-Verbose -Message "Removing logman Data Collector Set $($this.LifecycleState)"

            $null = logman.exe delete $this.LifecycleState
        }
    }
 
    <#
        This method is equivalent of the Test-TargetResource script function.
        It should return True or False, showing whether the resource
        is in a desired state.
    #>
    [bool] Test()
    {
        $present = $this.TestFilePath($this.Path)

        if ($this.Ensure -eq [Ensure]::Present)
        {
            return $present
        }
        else
        {
            return -not $present
        }
    }

    <#
        Helper method to check if the file exists and it is file
    #>
    [bool] TestFilePath([string] $location)
    {
        $present = $true

        $item = Get-ChildItem -LiteralPath $location -ErrorAction Ignore

        if ($item -eq $null)
        {
            $present = $false
        }
        elseif ($item.PSProvider.Name -ne "FileSystem")
        {
            throw "Path $($location) is not a file path."
        }
        elseif ($item.PSIsContainer)
        {
            throw "Path $($location) is a directory path."
        }

        return $present
    }
}