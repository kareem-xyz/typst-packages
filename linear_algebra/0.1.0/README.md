# linear_algebra (Typst Package)

A Typst package designed for linear algebra coursework and notes. It automates matrix multiplication and Gauss-Jordan elimination to Reduced Row Echelon Form (RREF) using exact rational arithmetic (fractions) rather than floating-point approximations.

## Features

- **Exact Fraction Arithmetic**: Tracks numerators and denominators explicitly; reduces fractions via Euclidean GCD.
- **RREF Step Generator**: Shows intermediate row additions, scaling, and row swaps with labeled transition arrows.
- **Matrix Multiplication Work**: Optionally generates expanded inner product terms.
- **Configurable Layout**: Supports toggling step verbosity and adjusting horizontal chaining limits.

---

## Installation

Clone this repository into your local Typst package directory:

### Linux 

bash
mkdir -p ~/.local/share/typst/packages/local/linear_algebra
git clone

