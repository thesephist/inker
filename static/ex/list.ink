` list function demos `

` tail recursive reversing a list `
reverse := list => (
	state := [len(list) - 1]
	reduce(list, (acc, item) => (
		acc.(state.0) := item
		state.0 := state.0 - 1
		acc
	), {})
)

` tail recursive map `
map := (list, f) => (
	reduce(list, (l, item) => (
		l.(len(l)) := f(item)
		l
	), {})
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

` create a simple list `
list := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

` utility functions for printing `
log := s => out(s + '
')

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



log('Mapped 1-10 list, squared
-> ' + stringList(map(list, n => n * n)))

log('Filtered 1-10 list, evens
-> ' + stringList(filter(list, n => n % 2 = 0)))

log('Reduced 1-10 list, multiplication
-> ' + string(reduce(list, (acc, n) => acc * n, 1)))

log('Reversing 1-10 list
-> ' + stringList(reverse(list)))

