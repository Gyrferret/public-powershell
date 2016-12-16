function Test-RDP {
    param (
    $IP,
    $Port = 3389,
    [int]$count = 3,
    [switch]$loop) 
BEGIN{}
PROCESS{
    $b = $count        
    for ($i = 0; $i -lt $b; $i ++) {
        $socket = New-Object System.Net.Sockets.TcpClient
        if ($socket.ConnectAsync($IP,$port).Wait('2000')) {
            $b = $i
            $i = $i + 1
            $Success = $True
       } else {
            Write-Warning "Failed to Connect to $IP on $Port"
       }
       $socket.Dispose()
       if ($loop) {
        $b = $i + 2
        }
    }

    if ($Success) {
        Write-Host "Succesfully Connected to $IP on $Port" -ForegroundColor Green
    }
            
}
END{}
}
