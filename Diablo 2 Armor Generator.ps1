$SuffixMods = import-csv -Path (Join-Path -Path $PSScriptRoot -ChildPath "SuffixMods.csv")
$ArmorTypeArray = @('Normal','Elite','Exceptional','Baller')

function Get-RElementalModifiers($cycles) {
    $range = [System.Collections.Generic.List[int]](0..3)
    $modifiers = @()

    foreach ($i in 0..$cycles) {
        $n = Get-Random -InputObject $range
        $modifiers += $n
        $range.Remove($n) | out-null
    }

    $fn = { param ( $rst, $counter)
        switch ($counter) {
            0 { $statMin = 5; $statMax = 11 }
            1 { $statMin = 11; $statMax = 26 }
            2 { $statMin = 26; $statMax = 36 }
            3 { $statMin = 36; $statMax = 51 }
        }
        return "+{0} $rst resist" -f (Get-Random -Minimum $statMin -Maximum $statMax)
    }

    $counter = 0
    $mods = switch ( $modifiers ) {
        0 { $fn.invoke("Fire", $counter++) }
        1 { $fn.invoke("Cold", $counter++) }
        2 { $fn.invoke("Lightning", $counter++) }
        3 { $fn.invoke("Poison", $counter++) }
    }
    return $mods -Join ", "
}

Function Create-Armor ($C1, $C2, $C3) {
    if ($C3 -notin ($ArmorTypeArray)) {
        Write-Error "Invalid Armor Tier. Please try again."
        exit 1
    }

    $Suffix = $SuffixMods[$(get-random -Minimum 0 -Maximum 4)]
    Write-Host $Suffix

    switch ($C3) {
         'Normal' {$De = Get-Random -minimum 10 -maximum 25; $Dem = .1; $Prefix = 'Bronze'; $Emc = 0}
         'Elite' {$De = Get-Random -minimum 28 -maximum 50; $Dem = .5; $Prefix = 'Silver'; $Emc = 1}
         'Exceptional' {$De = Get-Random -minimum 76 -maximum 100; $Dem = .75; $Prefix = 'Gold'; $Emc = 2}
         'Baller' {$De = Get-Random -minimum 176 -Maximum 200; $Dem = 1.0; $Prefix = "Platnium"; $Emc = 3}
    }

    $modifiers = Get-RElementalModifiers -c $Emc

    $armor = New-Object System.Collections.Generic.List[pscustomobject]

    $armor.add([pscustomobject]@{
        Class1 = [string]$C1
        Class2 = [string]$C2
        Class3 = [string]$C3
        Name = "$Prefix Breast plate $($Suffix['Name'])"
        DefenseBase = [int]$De
        DefenseModifier = [float]$Dem
        DefenseTotal = [int]($De + ($De * $Dem))
        ElementalModifier = $modifiers
        SuffixModifier = $Suffix.Modifier
        }
    )
    return $armor
}


$Armor = Create-Armor -C1 'Armor' -C2 'Chest' -C3 "$(read-host -Prompt "Select one from $($ArmorTypeArray)")"; $Armor
