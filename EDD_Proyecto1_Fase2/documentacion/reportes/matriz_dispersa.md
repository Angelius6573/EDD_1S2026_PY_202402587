# Matriz Dispersa
Aunque no es una lista enlazada en el sentido tradicional, la **matriz dispersa** es una estructura de datos lineal en cuanto a su almacenamiento interno: en lugar de reservar memoria para cada celda de una cuadrícula completa (lo que resultaría prohibitivo para matrices muy grandes con pocos datos), almacena únicamente los elementos **distintos de cero o vacíos**, indexados por su posición `(fila, columna)`.

```
Matriz real (5x5):         Representación interna:
   0  0  0  0  0               { "1,2" => 42 }
   0  0 42  0  0               { "3,4" => 17 }
   0  0  0  0  0               { "4,0" =>  5 }
   0  0  0  0 17
   5  0  0  0  0
```

En esta implementación se utiliza un hash de Perl donde la clave es el índice compuesto `"$fila,$columna"` y el valor es el dato almacenado. Acceder a una celda vacía simplemente retorna un valor por defecto sin que exista entrada alguna en memoria:

```perl
my $idx = "$fila,$columna";
return exists $self->{datos}{$idx} ? $self->{datos}{$idx} : { precio => 0, cantidad => 0 };
```

| Operación | Complejidad |
| --------- | ----------- |
| Insertar un elemento | O(1) |
| Obtener un elemento | O(1) |
| Recorrer una fila o columna | O(n) |
| Espacio en memoria | O(k), donde k = elementos no vacíos |

La gran ventaja frente a un arreglo bidimensional convencional es el ahorro de memoria: si una matriz de 1000×1000 tiene solo 50 celdas con datos, se almacenan únicamente esas 50 entradas en lugar de 1,000,000.

---
### Regresar al menú de listas
![<Regresar>](Reportes.md)
