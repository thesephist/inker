` prime sieve `

` is a single number prime? `
isPrime := n => (
  ip := (p, acc) => p :: {
    1 -> acc
    _ -> ip(p - 1, acc & n % p > 0)
  }
  ip(floor(pow(n, 0.5)), true)
)

` build a list of consecutive integers from 2 .. max `
buildConsecutive := max => (
  bc := (i, acc) => (
    i :: {
      (max + 1) -> acc
      _ -> (
        acc.(i - 2) := i
        bc(i + 1, acc)
      )
    }
  )
  bc(2, [])
)

` tail recursive filter `
filter := (list, f) => (
    reduce(list, (l, item) => (
        f(item) :: {
            true -> l.(len(l)) := item
        }
        l
    ), {})
)

` tail recursive reduce `
reduce := (list, f, acc) => (
    (reducesub := (idx, acc) => (
        idx :: {
            len(list) -> acc
            _ -> reducesub(
                idx + 1
                f(acc, list.(idx))
            )
        }
    )
    )(0, acc)
)

` tail recursive numeric list -> string converter `
stringList := list => (
    stringListRec := (l, start, acc) => (
        start :: {
            len(l) -> acc
            _ -> stringListRec(
                l
                start + 1
                (acc :: {
                    '' -> ''
                    _ -> acc + ', '
                }) + string(l.(start))
            )
        }
    )
    '[' + stringListRec(list, 0, '') + ']'
)

` utility function for printing things `
log := s => out(s + '
')

` primes under N are numbers 2 .. N, filtered by isPrime `
getPrimesUnder := n => filter(buildConsecutive(n), isPrime)

ps := getPrimesUnder(1000)
log(stringList(ps))
log('Total number of primes under 1000: ' + string(len(ps)))
