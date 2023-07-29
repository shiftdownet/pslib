
class IMergeableTable {
    [PsCustomObject[]]$table = $null

    [String]getPrimaryKey([PsCustomObject]$record) {
        throw "Not implemented error"
    }
}

class IMergeCondition {
    [bool]canMerge( [PsCustomObject]$src, [PsCustomObject]$dst ) {
        throw "Not implemented error"
    }
    [void]merge([PsCustomObject]$src, [PsCustomObject]$dst) {
        throw "Not implemented error"
    }
}

class TableMerger {
    [IMergeableTable]$src = $null
    [IMergeableTable]$dst = $null
    [PsCustomObject[]]$merged = @()
    [IMergeCondition]$condition = $null

    TableMerger( [IMergeableTable]$src, [IMergeableTable]$dst, [IMergeCondition]$mergeCondition ) {
        $this.src = $src
        $this.dst = $dst
        $this.condition = $mergeCondition
    }

    [void]merge() {
        # 処理時間をO(n^2)からO(n)にするためにインデックス作成
        $srcIndex = $this.createIndex($this.src)
        $dstIndex = $this.createIndex($this.dst)

        foreach ( $record in $dstIndex.psobject.properties ) {
            $key = $record.name
            $value = $record.value
            # dstRecordのプライマリーキーがsrcにも存在している
            if ( $null -ne $srcIndex.$key ) {
                if ( $this.condition.canMerge( $srcIndex.$key, $value ) ) {
                    $this.condition.merge( $srcIndex.$key, $value )
                }
            }
            $this.merged += $value
        }
    }

    [PsCustomObject]createIndex([IMergeableTable]$iMergeableTable) {
        $index = [PsCustomObject]@{}
        foreach ( $record in $iMergeableTable.table ) {
            $index | Add-Member -MemberType NoteProperty -Name $iMergeableTable.getPrimaryKey( $record ) -Value $record
        }
        return $index
    }
}
