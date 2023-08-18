$imagesFolder = "C:\Users\berni\Desktop\Splendor\Imagenes\Nivell3"

$images = Get-ChildItem $imagesFolder

foreach ($image in $images) {
    $imageName = $image.Name.Split(".")[0]
    for($i=2; $i -lt $imageName.Length;$i+=2){
	$coste = $imageName[$i]
	$color = $imageName[$i + 1]

    switch ($color) {
        "R" {$color = "red"}
        "G" {$color = "green"}
        "B" {$color = "blue"}
        "W" {$color = "white"}
        "N" {$color = "black"}
    }

    $imageId = $image.Name -replace ".jpg", ""
    $insertQuery = "INSERT INTO CosteCarta (IdColor, IdCarta, Coste) VALUES ('$color', '$imageId', $coste);"
    $insertQuery
}
}