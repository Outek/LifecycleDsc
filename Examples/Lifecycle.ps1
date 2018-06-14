Configuration Example
{
    Import-DSCResource -Module LifecycleDsc

        LifecycleDsc inuse {
            LifecycleState = 'inuse'
            Ensure         = 'Present'
            LifecyclePath  = 'C:\Sysapps\Lifecycle\lifecycle.exe'
        }
    }
    
Example

Start-DscConfiguration -Wait -Force Test