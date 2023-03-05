
using module ".\..\string\TemplateStringExpander.psm1"

$template = @"
<!----------------------------------------------------------
 ! テンプレート内に特定のキーワードを埋め込むことで、文字列の展開が行われます。
 !
 ! varriable:
 !      %{変数名} と記述することで変数に格納された値が展開されます。
 !      'root'と'_'は予約変数です。
 !      'root':
 !          トップ階層を表します。
 !      '_':
 !          イテレータが割り当てられます。トップ階層で参照した場合'root'を返します。
 ! repeat:
 !      <start_repeat:varriable> と <end_repeat:varriable> の間に記述した内容が要素数分リピートされ展開されます。
 !      辞書式または配列が指定可能です。
 !      イテレータは'_'に割り当てられます。
 !      辞書式の場合、キーと値にはそれぞれNameとValueでアクセス可能です。
 !
 !---------------------------------------------------------->
<html>
    <head>
        <title>%{_.Title}</title>
    </head>
    <body>
        <h1>%{_.Title}</h1>
        <a href='%{_.URL}'>%{_.URL}</a>
        <start_repeat:%{_.records}>
            <h2>%{_.Name}</h2>
            Record count : %{_.Value.Count}<br>
            <start_repeat:%{_.Value}>
                description: %{_.description}<br>
                timeSpent: %{_.timeSpent}<br>
                date: %{_.date}<br>
                status: %{_.status}<br>
            <end_repeat:%{_.Value}>
        <end_repeat:%{_.records}>
    </body>
</html>
"@

$data = @"
{
    "Title":"Example",
    "URL":"http://example.com",
    "records":{
        "Tony" : [
            {
                "description" : "descriptionA",
                "timeSpent" : "10",
                "date" : "2022-10-15",
                "status" : "uploaded"
            },
            {
                "description" : "descriptionB",
                "timeSpent" : "12",
                "date" : "2022-10-16",
                "status" : "error"
            }
        ],
        "Mike" : [
            {
                "description" : "descriptionC",
                "timeSpent" : "2",
                "date" : "2022-10-11",
                "status" : "uploaded"
            },
            {
                "description" : "descriptionD",
                "timeSpent" : "5",
                "date" : "2022-10-13",
                "status" : "error"
            },
            {
                "description" : "descriptionE",
                "timeSpent" : "5",
                "date" : "2022-10-13",
                "status" : "error"
            }
        ]    
    }
}
"@ | ConvertFrom-Json 



$test = [TemplateStringExpander]::new()
Write-Output $test.expand($data, $template)


