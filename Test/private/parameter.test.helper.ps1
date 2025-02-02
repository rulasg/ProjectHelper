# Variables used to the written output of the cmdlets 

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$VerboseParameters =@{
    VerboseAction = 'SilentlyContinue'
    VerboseVariable = 'verboseVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$WarningParameters = @{
    WarningAction = 'SilentlyContinue' 
    WarningVariable = 'warningVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$InfoParameters = @{
    InformationAction = 'SilentlyContinue'
    InformationVariable = 'infoVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$ErrorParameters = @{
    ErrorAction = 'Silently'
    ErrorVariable = 'errorVar'
}