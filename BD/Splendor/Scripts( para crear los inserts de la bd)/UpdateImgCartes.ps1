$folder = "C:\Users\berni\Desktop\Splendor\Imagenes\Cartas"

Get-ChildItem -Path $folder -Filter "*.jpg" | ForEach-Object {
	$file = $_.Name
	$id = $file.Substring(0, $file.Length - 4)
	$FileContent = [System.IO.File]::ReadAllBytes($folder + "\" + $file)

	$query = "UPDATE Carta SET img = 0x$([System.BitConverter]::ToString($FileContent).Replace('-','')) WHERE idCarta = '$id';"
	$query
}