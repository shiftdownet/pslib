

using module ".\..\table\TableMerger.psm1"

class QACTable : IMergeableTable {
    [String]getPrimaryKey( $record ){
        return $record.ID + $record.ErrorMessage
    }
}

class QACMerge:IMergeCondition {
    [bool]canMerge( [PsCustomObject]$src, [PsCustomObject]$dst ){
        return $dst.Comment -eq ""
    }
    [void]merge([PsCustomObject]$src, [PsCustomObject]$dst){
        $dst.Comment = $src.Comment
    }
}

$before = [QACTable]::new()
$before.table = Import-Csv "./sample_data_rev1.csv"
$after = [QACTable]::new()
$after.table = Import-Csv "./sample_data_rev2.csv"

$tableMerger = [TableMerger]::new( $before, $after, [QACMerge]::new() )
$tableMerger.merge()

$tableMerger.merged | Export-CSV -Path "./merged.csv" -NoTypeInformation
