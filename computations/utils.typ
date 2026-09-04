#import "@preview/spreet:0.1.0"
#import "@preview/lilaq:0.6.0" as lq
#let filter-only-floats = row => not row.any(col => type(col) != float)
#let q = 1.602176634e-19
