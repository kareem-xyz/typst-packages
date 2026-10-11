// --- Rational Arithmetic Engine (Exact Fractions) ---

#let rat-gcd(a, b) = {
  let x = calc.abs(a)
  let y = calc.abs(b)
  while y != 0 {
    let t = calc.rem(x, y)
    x = y
    y = t
  }
  if x == 0 { 1 } else { x }
}

#let rat(n, d: 1) = {
  let g = rat-gcd(n, d)
  let num = int(n / g)
  let den = int(d / g)
  if den < 0 {
    num = -num
    den = -den
  }
  (n: num, d: den)
}

#let to-rat(x) = {
  if type(x) == dictionary { x }
  else if type(x) == array { rat(x.at(0), d: x.at(1)) }
  else { rat(int(x), d: 1) }
}

#let rat-add(a, b) = rat(a.n * b.d + b.n * a.d, d: a.d * b.d)
#let rat-sub(a, b) = rat(a.n * b.d - b.n * a.d, d: a.d * b.d)
#let rat-mul(a, b) = rat(a.n * b.n, d: a.d * b.d)
#let rat-div(a, b) = rat(a.n * b.d, d: a.d * b.n)

#let format-cell(r) = {
  if r.d == 1 {
    r.n
  } else if r.n < 0 {
    eval("-" + str(calc.abs(r.n)) + "/" + str(r.d), mode: "math")
  } else {
    eval(str(r.n) + "/" + str(r.d), mode: "math")
  }
}

#let render-matrix(grid, augment: none) = {
  let formatted = grid.map(row => row.map(format-cell))
  if augment != none {
    math.mat(augment: augment, ..formatted)
  } else {
    math.mat(..formatted)
  }
}

#let set-row(grid, r, new-row) = {
  let next = ()
  for i in range(grid.len()) {
    if i == r { next.push(new-row) } else { next.push(grid.at(i)) }
  }
  next
}

#let render-row(start-mat: none, steps, augment: none) = {
  let terms = ()
  if start-mat != none {
    terms.push(render-matrix(start-mat, augment: augment))
  }
  for s in steps {
    let lbl = if s.ops.len() == 1 { s.ops.at(0) } else { math.vec(delim: none, ..s.ops) }
    terms.push(($ limits(-->)^(#lbl) $).body)
    terms.push(render-matrix(s.matrix, augment: augment))
  }
  math.equation(block: true, terms.join([ ]))
}

// --- Public Function 1: Matrix Multiplication ---

#let mat-mul(A, B, verbose: false) = {
  let rows-A = A.len()
  let cols-A = A.at(0).len()
  let rows-B = B.len()
  let cols-B = B.at(0).len()

  assert(cols-A == rows-B, message: "Matrix dimensions do not match for multiplication.")

  let result = range(rows-A).map(i => {
    range(cols-B).map(j => {
      range(cols-A).map(k => A.at(i).at(k) * B.at(k).at(j)).sum()
    })
  })

  if verbose {
    let work = range(rows-A).map(i => {
      range(cols-B).map(j => {
        let terms = range(cols-A).map(k => {
          let a = A.at(i).at(k)
          let b = B.at(k).at(j)
          let a-str = if a < 0 { "(" + str(a) + ")" } else { str(a) }
          let b-str = if b < 0 { "(" + str(b) + ")" } else { str(b) }
          a-str + " dot " + b-str
        })
        eval(terms.join(" + "), mode: "math")
      })
    })
    $ #math.mat(..A) #math.mat(..B) = #math.mat(..work) = #math.mat(..result) $
  } else {
    $ #math.mat(..A) #math.mat(..B) = #math.mat(..result) $
  }
}

// --- Public Function 2: RREF ---

#let mat-rref(M, augment: none, verbose: true, per-row: 2) = {
  let rows = M.len()
  let cols = M.at(0).len()
  let grid = M.map(row => row.map(to-rat))
  
  let steps = ()
  let pivot-row = 0
  let max-cols = if augment != none { augment } else { cols }

  for c in range(max-cols) {
    if pivot-row >= rows { break }

    let p = -1
    for r in range(pivot-row, rows) {
      if grid.at(r).at(c).n != 0 {
        p = r
        break
      }
    }
    if p == -1 { continue }

    if p != pivot-row {
      let r1 = grid.at(pivot-row)
      let r2 = grid.at(p)
      grid = set-row(set-row(grid, pivot-row, r2), p, r1)
      let op = eval("R_" + str(pivot-row + 1) + " <-> R_" + str(p + 1), mode: "math")
      steps.push((ops: (op,), matrix: grid))
    }

    let pv = grid.at(pivot-row).at(c)
    if not (pv.n == 1 and pv.d == 1) {
      let inv = rat-div(rat(1), pv)
      let scaled-row = grid.at(pivot-row).map(x => rat-mul(x, inv))
      grid = set-row(grid, pivot-row, scaled-row)
      
      let scale-str = if inv.d == 1 { str(inv.n) } else { str(inv.n) + "/" + str(inv.d) }
      let op = if inv.n == -1 and inv.d == 1 {
        eval("R_" + str(pivot-row + 1) + " <- -R_" + str(pivot-row + 1), mode: "math")
      } else {
        eval("R_" + str(pivot-row + 1) + " <- " + scale-str + " thin R_" + str(pivot-row + 1), mode: "math")
      }
      steps.push((ops: (op,), matrix: grid))
    }

    let elim-ops = ()
    for r in range(rows) {
      if r != pivot-row and grid.at(r).at(c).n != 0 {
        let factor = grid.at(r).at(c)
        let new-row = range(cols).map(k => {
          rat-sub(grid.at(r).at(k), rat-mul(factor, grid.at(pivot-row).at(k)))
        })
        grid = set-row(grid, r, new-row)

        let op = if factor.n == 1 and factor.d == 1 {
          eval("R_" + str(r + 1) + " <- R_" + str(r + 1) + " - R_" + str(pivot-row + 1), mode: "math")
        } else if factor.n == -1 and factor.d == 1 {
          eval("R_" + str(r + 1) + " <- R_" + str(r + 1) + " + R_" + str(pivot-row + 1), mode: "math")
        } else if factor.n > 0 {
          let f-str = if factor.d == 1 { str(factor.n) } else { str(factor.n) + "/" + str(factor.d) }
          eval("R_" + str(r + 1) + " <- R_" + str(r + 1) + " - " + f-str + " thin R_" + str(pivot-row + 1), mode: "math")
        } else {
          let pos = rat(-factor.n, d: factor.d)
          let f-str = if pos.d == 1 { str(pos.n) } else { str(pos.n) + "/" + str(pos.d) }
          eval("R_" + str(r + 1) + " <- R_" + str(r + 1) + " + " + f-str + " thin R_" + str(pivot-row + 1), mode: "math")
        }
        elim-ops.push(op)
      }
    }

    if elim-ops.len() > 0 {
      steps.push((ops: elim-ops, matrix: grid))
    }

    pivot-row += 1
  }

  if not verbose {
    $ #render-matrix(grid, augment: augment) $
  } else {
    let initial-grid = M.map(r => r.map(to-rat))
    if steps.len() == 0 {
      $ #render-matrix(initial-grid, augment: augment) $
    } else {
      let first-count = if per-row == 1 { 0 } else { per-row - 1 }
      let first-steps = if first-count > 0 {
        steps.slice(0, calc.min(first-count, steps.len()))
      } else {
        ()
      }
      
      render-row(start-mat: initial-grid, first-steps, augment: augment)
      
      let idx = first-steps.len()
      while idx < steps.len() {
        let chunk = steps.slice(idx, calc.min(idx + per-row, steps.len()))
        render-row(start-mat: none, chunk, augment: augment)
        idx += per-row
      }
    }
  }
}
