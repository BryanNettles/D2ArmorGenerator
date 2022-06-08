$SuffixMods = import-csv -Path ".\SuffixMods.csv"
$ArmorTypeArray = @('Normal','Elite','Exceptional','Baller')

Function Get-RElementalModifier($C)
{

$EStart = new-object system.collections.generic.list[object]
$Estart.AddRange(0..3)
$Emod = @()
$Etrack = @()

 Function Get-Modifier ($GMN, $C){
        
        Switch ($C)
        {
        0 {$GMMin = 5;$GMMax = 11}
        1 {$GMMin = 11;$GMMax = 26}
        2 {$GMMin = 26;$GMMax = 36}
        3 {$GMMin = 36;$GMMax = 51}
        }

        Switch ($GMN)
        {
        0 {$GM = '+' + [string]$(Get-Random -Minimum $GMMin -Maximum $GMMax) + ' Fire resist'}
        1 {$GM = '+' + [string]$(Get-Random -Minimum $GMMin -Maximum $GMMax) + ' Cold resist'}
        2 {$GM = '+' + [string]$(Get-Random -Minimum $GMMin -Maximum $GMMax) + ' Lightning resist'}
        3 {$GM = '+' + [string]$(Get-Random -Minimum $GMMin -Maximum $GMMax) + ' Poison resist'}
        }
        Return $GM
    }


$Count = 0



    While ($Count -le $C){


        $Count ++
        $E = get-random -InputObject $Estart
        $EMod += $(Get-Modifier -GMN $E)
        $Estart.Remove($E) | out-null

    }

Return $Emod

}




Function Create-Armor ($C1, $C2, $C3){

    If ($C3 -notin ($ArmorTypeArray)){
        return "Invalid Armor Tier. Please try again."
    }


$Suffix = $Suffixmods[$(get-random -Minimum 0 -Maximum 4)]


Switch ($C3)
{
 'Normal' {$De = Get-Random -minimum 10 -maximum 25;$Dem = .1;$Prefix = 'Bronze';$Emc = 0}
 'Elite' {$De = Get-Random -minimum 28 -maximum 50;$Dem = .5;$Prefix = 'Silver';$Emc = 1}
 'Exceptional' {$De = Get-Random -minimum 76 -maximum 100;$Dem = .75;$Prefix = 'Gold';$Emc = 2}
 'Baller' {$De = Get-Random -minimum 176 -Maximum 200;$Dem = 1.0;$Prefix = "Platnium";$Emc = 3}
}

$Emod = Get-RElementalModifier -c $Emc



$A = new-object system.collections.generic.list[pscustomobject]

$A.add([pscustomobject]@{
    Class1 = [string]$C1
    Class2 = [string]$C2
    Class3 = [string]$C3
    Name = "$Prefix Breast plate $($Suffix.name)"
    DefenseBase = [int]$De
    DefenseModifier = [float]$Dem
    DefenseTotal = [int]($De + ($De * $Dem))
    ElementalModifier = $Emod
    SuffixModifier = $Suffix.Modifier
    }
)


return $A

}


$Armor = Create-Armor -C1 'Armor' -C2 'Chest' -C3 "$(read-host -Prompt "Select one from $($ArmorTypeArray)")"; $Armor


