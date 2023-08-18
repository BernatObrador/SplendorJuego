$imagesFolder = "C:\Users\berni\Desktop\Splendor\Imagenes\Nivell2"

$images = Get-ChildItem $imagesFolder

foreach ($image in $images) {
    $imageName = $image.Name.Split(".")[0]
    $points = $imageName[0]
    $color = $imageName[1]

    switch ($color) {
        "R" {$color = "Red"}
        "G" {$color = "Green"}
        "B" {$color = "Blue"}
        "W" {$color = "White"}
        "N" {$color = "Black"}
    }

    $imageId = $image.Name -replace ".jpg", ""
    $insertQuery = "INSERT INTO Carta (IdCarta, Puntos, Nivel, IdColor) VALUES ('$imageId' , $points, '2', '$color');"
    $insertQuery
}