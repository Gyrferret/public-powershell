$time = (Get-Date).AddDays(-100)
$size = 30MB
$path = "C:\Users\Awesome\Downloads\"

Get-ChildItem $path | where length -GT $size

Get-ChildItem $path | where creationtime -gt $time

Get-ChildItem $path | where creationtime -lt $time

