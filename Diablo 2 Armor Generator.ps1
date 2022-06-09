$SuffixMods = import-csv -Path (Join-Path -Path $PSScriptRoot -ChildPath "SuffixMods.csv")

$ArmorTypes = [ordered]@{}
$ArmorTypes.Normal = @{
    modifiers = 1
    elementStatRange = 5..11
    defenseStatRange = 10..25
    defenseModifier = 1.1
    prefix = "Bronze"
}
$ArmorTypes.Elite = @{
    modifiers = 2
    elementStatRange = 11..26
    defenseStatRange = 28..50
    defenseModifier = 1.5
    prefix = "Silver"
}
$ArmorTypes.Exceptional = @{
    modifiers = 3
    elementStatRange = 26..36
    defenseStatRange = 76..100
    defenseModifier = 1.75
    prefix = "Gold"
}
$ArmorTypes.Baller = @{
    modifiers = 4
    elementStatRange = 36..51
    defenseStatRange = 176..200
    defenseModifier = 2.0
    prefix = "Platinum"
}

function Get-RElementalModifiers($armorType) {
    $range = [System.Collections.Generic.List[int]](0..3)
    $modifiers = @()

    foreach ($i in 1..$armorType.modifiers) {
        $n = Get-Random -InputObject $range
        $modifiers += $n
        $range.Remove($n) | out-null
    }

    $fn = { param ( $rst, $statRange )
        return "+{0} $rst resist" -f (Get-Random -InputObject $armorType.elementStatRange)
    }.GetNewClosure()

    $mods = switch ( $modifiers ) {
        0 { $fn.invoke("Fire") }
        1 { $fn.invoke("Cold") }
        2 { $fn.invoke("Lightning") }
        3 { $fn.invoke("Poison") }
    }
    return $mods -Join ", "
}

Function Create-Armor ($C1, $C2, $type) {
    if (-not $ArmorTypes.Keys -contains $type) {
        Write-Error "Invalid Armor Tier. Please try again."
        exit 1
    }
    $armorType = $ArmorTypes[$type]

    $Suffix = $SuffixMods[$(get-random -Minimum 0 -Maximum 4)]
    $modifiers = Get-RElementalModifiers -armorType $armorType

    $armor = New-Object System.Collections.Generic.List[pscustomobject]
    $defense = Get-Random -InputObject $armorType.defenseStatRange

    $armor.add([pscustomobject]@{
        Class1 = [string]$C1
        Class2 = [string]$C2
        Class3 = [string]$type
        Name = "$($armorType.prefix) Breast plate $($Suffix['Name'])"
        DefenseBase = [int]$defense
        DefenseModifier = $armorType.defenseModifier
        DefenseTotal = [int]($defense * $armorType.defenseModifier)
        ElementalModifier = $modifiers
        SuffixModifier = $Suffix.Modifier
        }
    )
    return $armor
}


$Armor = Create-Armor -C1 'Armor' -C2 'Chest' -type "$(read-host -Prompt "Select one from: $($ArmorTypes.keys)")"
Write-Output $Armor
