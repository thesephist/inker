` prime sieve `

` is a single number prime? `
isPrime := n => (
	` is n coprime with nums < p? `
	max := floor(pow(n, 0.5)) + 1
	(ip := p => p :: {
		max -> true
		_ -> n % p :: {
			0 -> false
			_ -> ip(p + 1)
		}
	})(2) ` start with smaller # = more efficient `
)

` build a list of consecutive integers from 2 .. max `
buildConsecutive := max => (
	peak := max + 1
	acc := []
	(bc := i => i :: {
		peak -> ()
		_ -> (
			acc.(i - 2) := i
			bc(i + 1)
		)
	})(2)
	acc
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
	length := len(list)
	(reducesub := (idx, acc) => (
		idx :: {
			length -> acc
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
	length := len(list)
	stringListRec := (start, acc) => (
		start :: {
			length -> acc
			_ -> stringListRec(
				start + 1
				(acc :: {
					'' -> ''
					_ -> acc + ', '
				}) + string(list.(start))
			)
		}
	)
	'[' + stringListRec(0, '') + ']'
)

` utility function for printing things `
log := s => out(s + '
')

` primes under N are numbers 2 .. N, filtered by isPrime `
getPrimesUnder := n => filter(buildConsecutive(n), isPrime)

ps := getPrimesUnder(10000)
log(stringList(ps))
log('Total number of primes under 10000: ' + string(len(ps)))
