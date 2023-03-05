
class TemplateStringExpander {
    [PSCustomObject]$root_p

    [String]expand([PSCustomObject]$root_p, [String]$template) {
        $this.root_p = $root_p
        return $this.repeat($root_p, $template)
    }

    [String]repeat([PSCustomObject]$parent, $template) {
        $root = $this.root_p
        $_ = $parent
        if ( $template -match "([\s\S]+?)?<start_repeat:%\{(.+?)\}>([\s\S]+)?" ) {
            $before = $Matches.1
            $repeat_itr = $Matches.2
            $after = $Matches.3

            if ( $after -match "([\s\S]+?)?<end_repeat:%\{$repeat_itr\}>([\s\S]+)?" ) {
                $internal = $Matches.1
                $after = $Matches.2

                $itr = Invoke-Expression -Command "`$(`$$repeat_itr)"

                if ( $itr -is [System.Management.Automation.PSCustomObject] ) {
                    $itr = $itr.psobject.Properties
                }

                $r = ""
                $itr | % {
                    $r += $this.repeat($_, $internal)
                }
                $expand = $this.repeat($parent, $before) + $r + $this.repeat($parent, $after)
                return Invoke-Expression -Command "[String]`"$expand`""
            }
            else {
                throw "Syntax error. end_repeat:$repeat_itr was not found."
                return "Syntax error. end_repeat:$repeat_itr was not found."
            }
        }
        $r = $template -replace "%\{(.+?)\}", '$(<ESC_DOLLAR>$1)'
        $r = $r -replace "<ESC_DOLLAR>", '$'
        return Invoke-Expression -Command "[String]`"$r`""
    }
}
