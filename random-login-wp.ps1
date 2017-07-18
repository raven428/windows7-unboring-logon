$src = 'http://loremflickr.com/1920/1200/wallpaper'
$dst = 'C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg'
$max_tries = 10

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$try_count = 0
while($try_count++ -lt $max_tries) {
 try {
  $request = [System.Net.HttpWebRequest]::Create((New-Object System.Uri($src)))
  $request.set_Timeout(11111)
  $pic = [System.Drawing.Image]::FromStream($request.GetResponse().GetResponseStream())
  break
 } catch {
  write-host -NoNewLine "fail #[$try_count]... "
  sleep 1
  if($try_count -lt $max_tries) { write-host "trying again!" }
 }
}
if($try_count -gt $max_tries) {
 write-host "total fail :("
} else {
 $myEncoder = [System.Drawing.Imaging.Encoder]::Quality
 $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
 $quality = 100
 do {
  Write-Host -NoNewline "trying quality [$quality]... "
  $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality--)
  $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | where { $_.MimeType -eq 'image/jpeg' }
  $mempic = New-Object System.IO.MemoryStream
  $pic.Save($mempic, $myImageCodecInfo, $($encoderParams))
  Write-Host $mempic.length
 } until($mempic.length -le 256000)
 $filepic = new-object IO.FileStream("${dst}.temp", [IO.FileMode]::Create)
 Write-Host $filepic.Length
 $mempic.Seek(0, [IO.SeekOrigin]::Begin)
 $mempic.CopyTo($filepic)
 Write-Host $filepic.Length
 $filepic.Dispose()
 move-item -force -path "${dst}.temp" -destination $dst
}
