# Carga Masiva de Medicamentos

El usuario al elegir la opción 2 será llevado a un menú de carga para archivos **.csv**, al igual que en la carga individual de medicamentos, el archivo deberá contener los encabezados con los términos exactos presentados en la carga individual para hacer una asociación correcta.

| codigo | nombre | principio_activo | laboratorio | precio_unitario | cantidad | fecha_vencimiento | nivel_minimo |
| --- | --- | --- | --- | --- | --- | --- | --- |
| MED001 | Glucophage | Metformina | BioFarma | 3.90 | 860 | 2026-11-15 | 600 |
| MED002 | Zantac | Ranitidina | GenericLab | 6.30 | 355 | 2026-07-20 | 350 |
| MED003 | Cozaar | Losartán | CardioMed | 8.20 | 430 | 2027-01-10 | 450 |

---
## Explicación de la Lectura de Archivos CSV
Con la librería **Text::CSV** se obtiene el método "**new()**" y con el los parámetros "*binary => 1*" y "*auto_diag => 1*" que permiten leer caracteres *UTF-8* e identificar errores de mal formateo respectivamente.
A la vez se obtiene el método "**getline()**" que permite leer y almacenar en un arreglo los nombres de las columnas, este arreglo se usa como punto de referencia en un foreach para leer el resto de líneas y asociar su contenido con su columna asociada correctamente.
Se declara un *hash* "**%dato**" para guardar los datos en una sola línea y para a continuación hacer una asignación *hash-array*.
En código se ve de la siguiente manera:
```perl
while (my $fila = $csv->getline($fh)) {
    my %dato;
    @dato{@$encabezado} = @$fila;  # Crear hash en memoria para cada encabezado
    push @datos, \%dato;
}
```
Visualmente con un ejemplo sencillo podría verse de la siguiente forma:
```python
  encabezado = ["codigo", "nombre", "precio_unitario"]
  fila = ["MED001", "Paracetamol", 15.49]
  # resultado tras el push:
  %dato = (
    codigo => "MED001",
    nombre => "Paracetamol",
    precio_unitario => "15.49"
  )
```

