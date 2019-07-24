` the ink standard library `

log := val => out(string(val) + '
')

scan := callback => (
	acc := ['']
	cb := evt => evt.type :: {
		'end' -> callback(acc.0)
		'data' -> (
			acc.0 :=
				acc.0 + slice(evt.data, 0, len(evt.data) - 1)
			false
		)
	}
	in(cb)
)

` hexadecimal conversion utility functions `
hToN := {0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 'a': 10, 'b': 11, 'c': 12, 'd': 13, 'e': 14, 'f': 15}
nToH := '0123456789abcdef'

` take number, return hex string `
hex := n => (
	(sub := (p, acc) => p < 16 :: {
		true -> nToH.(p) + acc
		false -> sub(floor(p / 16), nToH.(p % 16) + acc)
	})(floor(n), '')
)

` take hex string, return number `
xeh := s => (
	` i is the num of places from the left, 0-indexed `
	max := len(s)
	(sub := (i, acc) => i :: {
		max -> acc
		_ -> sub(i + 1, acc * 16 + hToN.(s.(i)))
	})(0, 0)
)

` like Python's range(), but no optional arguments `
range := (start, end, step) => (
	span := end - start
	sub := (i, v, acc) => (v - start) / span < 1 :: {
		true -> (
			acc.(i) := v
			sub(i + 1, v + step, acc)
		)
		false -> acc
	}

	` preempt potential infinite loops `
	(end - start) / step > 0 :: {
		true -> sub(0, start, [])
		false -> []
	}
)

` clamp start and end numbers to ranges, such that
	start < end. Utility used in slice/sliceList`
clamp := (start, end, min, max) => (
	start := (start < min :: {
		true -> min
		false -> start
	})
	end := (end < min :: {
		true -> min
		false -> end
	})
	end := (end > max :: {
		true -> max
		false -> end
	})
	start := (start > end :: {
		true -> end
		false -> start
	})

	{
		start: start
		end: end
	}
)

` get a substring of a given string `
slice := (str, start, end) => (
	` bounds checks `
	x := clamp(start, end, 0, len(str))
	start := x.start
	end := x.end

	max := end - start
	(sub := (i, acc) => i :: {
		max -> acc
		_ -> sub(i + 1, acc + str.(start + i))
	})(0, '')
)

` get a sub-list of a given list `
sliceList := (list, start, end) => (
	` bounds checks `
	x := clamp(start, end, 0, len(list))
	start := x.start
	end := x.end

	max := end - start
	(sub := (i, acc) => i :: {
		max -> acc
		_ -> sub(i + 1, acc.(i) := list.(start + i))
	})(0, [])
)

` join one list to the end of another, return the original first list `
append := (base, child) => (
	baseLength := len(base)
	childLength := len(child)
	(sub := i => i :: {
		childLength -> base
		_ -> (
			base.(baseLength + i) := child.(i)
			sub(i + 1)
		)
	})(0)
)

` join one list to the end of another, return the third list `
join := (base, child) => append(clone(base), child)

` clone a composite value `
clone := x => type(x) :: {
	'string' -> '' + x
	'composite' -> reduce(keys(x), (acc, k) => acc.(k) := x.(k), {})
	_ -> x
}

` tail recursive numeric list -> string converter `
stringList := list => '[' + cat(map(list, x => string(x)), ', ') + ']'

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
	idx := [0]
	reduce(list, (l, item) => (
		l.(idx.0) := f(item)
		idx.0 := idx.0 + 1
		l
	), {})
)

` tail recursive filter `
filter := (list, f) => (
	idx := [0]
	reduce(list, (l, item) => (
		f(item) :: {
			true -> (
				l.(idx.0) := item
				idx.0 := idx.0 + 1
			)
		}
		l
	), {})
)

` tail recursive reduce `
reduce := (list, f, acc) => (
	length := len(list)
	(sub := (i, acc) => i :: {
		length -> acc
		_ -> sub(
			i + 1
			f(acc, list.(i))
		)
	})(0, acc)
)

` concatenate (join) a list of strings into a string `
cat := (list, joiner) => (
	length := len(list) :: {
		0 -> ''
		_ -> (sub := (i, acc) => i :: {
			length -> acc
			_ -> sub(i + 1, acc + joiner + list.(i))
		})(1, list.0)
	}
)

` for-each loop over a list `
each := (list, f) => (
	length := len(list)
	(sub := i => i :: {
		length -> ()
		_ -> (
			f(list.(i))
			sub(i + 1)
		)
	})(0)
)

` encode string buffer into a number list `
encode := str => (
	max := len(str)
	(sub := (i, acc) => i :: {
		max -> acc
		_ -> sub(i + 1, acc.(i) := point(str.(i)))
	})(0, [])
)

` decode number list into an ascii string `
decode := data => reduce(data, (acc, cp) => acc + char(cp), '')

` utility for reading an entire file `
readFile := (path, callback) => (
	BUFSIZE := 4096 ` bytes `
	sent := [false]
	(accumulate := (offset, acc) => read(path, offset, BUFSIZE, evt => (
		sent.0 :: {false -> (
			evt.type :: {
				'error' -> (
					sent.0 := true
					callback(())
				)
				'data' -> (
					dataLen := len(evt.data)
					dataLen = BUFSIZE :: {
						true -> accumulate(offset + dataLen, acc + evt.data)
						false -> (
							sent.0 := true
							callback(acc + evt.data)
						)
					}
				)
			}
		)}
	)))(0, '')
)

` utility for writing an entire file
	it's not buffered, because it's simpler, but may cause jank later
	we'll address that if/when it becomes a performance issue `
writeFile := (path, data, callback) => (
	sent := [false]
	write(path, 0, data, evt => (
		sent.0 :: {false -> (
			sent.0 := true
			evt.type :: {
				'error' -> callback(())
				'end' -> callback(true)
			}
		)}
	))
)

` template formatting with {{ key }} constructs `
format := (raw, values) => (
	` parser state `
	state := {
		` current position in raw `
		idx: 0
		` parser internal state:
			0 -> normal
			1 -> seen one {
			2 -> seen two {
			3 -> seen a valid } `
		which: 0
		` buffer for currently reading key `
		key: ''
		` result build-up buffer `
		buf: ''
	}

	` helper function for appending to state.buf `
	append := c => state.buf := state.buf + c

	` read next token, update state `
	readNext := () => (
		c := raw.(state.idx)

		state.which :: {
			0 -> c :: {
				'{' -> state.which := 1
				_ -> append(c)
			}
			1 -> c :: {
				'{' -> state.which := 2
				` if it turns out that earlier brace was not
					a part of a format expansion, just backtrack `
				_ -> (
					append('{' + c)
					state.which := 0
				)
			}
			2 -> c :: {
				'}' -> (
					` insert key value `
					state.buf := state.buf + string(values.(state.key))
					state.key := ''
					state.which := 3
				)
				` ignore spaces in keys -- not allowed `
				' ' -> ()
				_ -> state.key := state.key + c
			}
			3 -> c :: {
				'}' -> state.which := 0
				` ignore invalid inputs -- treat them as nonexistent `
				_ -> ()
			}
		}

		state.idx := state.idx + 1
	)

	` main recursive sub-loop `
	max := len(raw)
	(sub := () => state.idx < max :: {
		true -> (
			readNext()
			sub()
		)
		false -> state.buf
	})()
)
