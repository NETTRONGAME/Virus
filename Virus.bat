<# :
@echo off
chcp 65001 >nul
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Invoke-Expression ([System.IO.File]::ReadAllText('%~f0', [System.Text.Encoding]::UTF8))"
exit /b
#>

Add-Type -AssemblyName System.Windows.Forms, System.Drawing, System.Speech

$f = New-Object System.Windows.Forms.Form
$f.FormBorderStyle = 'None'
$f.WindowState = 'Maximized'
$f.TopMost = $true
$f.BackColor = [System.Drawing.Color]::Black
$f.KeyPreview = $true
$f.Add_KeyDown({
    if ($_.KeyCode -in 'Escape', 'Space', 'Return') {
        $script:stop = $true
        $f.Close()
    }
})

$script:scene = 1
$script:pulse = $true
$script:stop = $false

$skullMap = @(
    "          1111111111          ",
    "       1111111111111111       ",
    "     11111111111111111111     ",
    "    1111111111111111111111    ",
    "   111111111111111111111111   ",
    "   111111111111111111111111   ",
    "   111110000011110000011111   ",
    "   111100000001100000001111   ",
    "   111100000001100000001111   ",
    "    1111000001111000001111    ",
    "     11111111100111111111     ",
    "      111111100001111111      ",
    "       1111111111111111       ",
    "        11111111111111        ",
    "         110110110110         ",
    "         110110110110         ",
    "          1111111111          "
)

$f.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $w = $f.ClientSize.Width
    $h = $f.ClientSize.Height
    $cx = [int]($w / 2)
    $cy = [int]($h / 2)

    if ($script:scene -eq 1) {
        $penEye = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 190, 190), 8)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $ew = 260; $eh = 135
        $path.AddBezier($cx - $ew, $cy - 40, $cx - 110, $cy - 40 - $eh, $cx + 110, $cy - 40 - $eh, $cx + $ew, $cy - 40)
        $path.AddBezier($cx + $ew, $cy - 40, $cx + 110, $cy - 40 + $eh, $cx - 110, $cy - 40 + $eh, $cx - $ew, $cy - 40)
        $g.DrawPath($penEye, $path)
        $g.DrawEllipse($penEye, $cx - 72, $cy - 112, 144, 144)

        $brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Red)
        $g.FillEllipse($brushRed, $cx - 14, $cy - 54, 28, 28)

        $fontMain = New-Object System.Drawing.Font('Impact', 46)
        $fontSub = New-Object System.Drawing.Font('Consolas', 16)
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $brushGray = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 200, 200))
        $brushDim = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Gray)

        $g.DrawString("В А С   З А М Е Т И Л И", $fontMain, $brushGray, $cx, $cy + 95, $sf)
        $g.DrawString("[ ОБЪЕКТ: $env:COMPUTERNAME // $env:USERNAME ]", $fontSub, $brushDim, $cx, $cy + 185, $sf)
    }
    elseif ($script:scene -eq 2) {
        $fontBin = New-Object System.Drawing.Font('Consolas', 18, [System.Drawing.FontStyle]::Bold)
        $brushBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(55, 0, 0))
        $cSkull = if ($script:pulse) { [System.Drawing.Color]::FromArgb(255, 25, 25) } else { [System.Drawing.Color]::FromArgb(140, 0, 0) }
        $brushSkull = New-Object System.Drawing.SolidBrush($cSkull)

        $cellW = 24; $cellH = 26
        $cols = [int]($w / $cellW) + 1
        $rows = [int]($h / $cellH) + 1
        $startX = [int](($cols - 30) / 2)
        $startY = [int](($rows - 17) / 2) - 1
        $rnd = New-Object System.Random

        for ($r = 0; $r -lt $rows; $r++) {
            for ($c = 0; $c -lt $cols; $c++) {
                $bit = if ($rnd.Next(0, 2) -eq 0) { "0" } else { "1" }
                $mr = $r - $startY
                $mc = $c - $startX
                $isSkull = $false
                if ($mr -ge 0 -and $mr -lt 17 -and $mc -ge 0 -and $mc -lt 30) {
                    if ($skullMap[$mr][$mc] -eq '1') { $isSkull = $true }
                }
                $b = if ($isSkull) { $brushSkull } else { $brushBg }
                $g.DrawString($bit, $fontBin, $b, $c * $cellW, $r * $cellH)
            }
        }
        $fontWarn = New-Object System.Drawing.Font('Consolas', 22, [System.Drawing.FontStyle]::Bold)
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("[ КРИТИЧЕСКИЙ СБОЙ ЦЕЛОСТНОСТИ СИСТЕМЫ ]", $fontWarn, $brushSkull, $cx, $h - 90, $sf)
    }
    elseif ($script:scene -eq 3) {
        $g.Clear([System.Drawing.Color]::FromArgb(0, 120, 215))
        $white = [System.Drawing.Brushes]::White
        $x = [int]($w * 0.12)
        $y = [int]($h * 0.16)

        $g.DrawString(":(", (New-Object System.Drawing.Font('Segoe UI', 95)), $white, $x, $y)
        $txt = "На вашем ПК возникла проблема, и его необходимо перезагрузить.`nМы лишь собираем некоторые сведения об ошибке, а затем будет`nвыполнена автоматическая перезагрузка.`n`nЗавершено: 100%"
        $g.DrawString($txt, (New-Object System.Drawing.Font('Segoe UI', 22)), $white, $x, $y + 180)

        $qrX = $x; $qrY = $y + 390
        $g.FillRectangle($white, $qrX, $qrY, 110, 110)
        $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 120, 215))
        $g.FillRectangle($blueBrush, $qrX + 12, $qrY + 12, 28, 28)
        $g.FillRectangle($white, $qrX + 18, $qrY + 18, 16, 16)
        $g.FillRectangle($blueBrush, $qrX + 70, $qrY + 12, 28, 28)
        $g.FillRectangle($white, $qrX + 76, $qrY + 18, 16, 16)
        $g.FillRectangle($blueBrush, $qrX + 12, $qrY + 70, 28, 28)
        $g.FillRectangle($white, $qrX + 18, $qrY + 76, 16, 16)
        $g.FillRectangle($blueBrush, $qrX + 52, $qrY + 52, 22, 22)

        $info = "Дополнительную информацию об этой проблеме и возможных способах ее решения см. на странице https://windows.com`n`nПри обращении в службу поддержки предоставьте следующие данные:`nКод остановки: INTRUSION_DETECTED_0x0000DEAD`nЧто вызвало проблему: null_watcher_x64.sys ($env:COMPUTERNAME)`n`n[Нажмите ESC, Пробел или Enter для выхода]"
        $g.DrawString($info, (New-Object System.Drawing.Font('Segoe UI', 14)), $white, $qrX + 135, $qrY - 5)
    }
})

$f.Add_Shown({
    $f.Activate()
    $f.Refresh()
    $ws = New-Object -ComObject WScript.Shell
    $sp = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $sp.Rate = -2

    [console]::beep(900, 120)
    [console]::beep(700, 120)
    [console]::beep(1100, 300)
    $sp.SpeakAsync("We see you, $env:USERNAME.") | Out-Null

    for ($i = 0; $i -lt 65; $i++) {
        if ($script:stop) { return }
        if ($i % 5 -eq 0) { $ws.SendKeys('{CAPSLOCK}'); $ws.SendKeys('{SCROLLLOCK}') }
        $p = [System.Windows.Forms.Cursor]::Position
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($p.X + (Get-Random -Min -90 -Max 91)), ($p.Y + (Get-Random -Min -90 -Max 91)))
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 40
    }

    $script:scene = 2
    [console]::beep(350, 450)
    for ($j = 0; $j -lt 14; $j++) {
        if ($script:stop) { return }
        $script:pulse = ($j % 2 -eq 0)
        $f.Invalidate()
        $f.Update()
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 180
    }

    $script:scene = 3
    $f.Invalidate()
    $f.Update()
    [console]::beep(250, 500)
})

[void]$f.ShowDialog()
