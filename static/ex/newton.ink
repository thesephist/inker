` implementation of Newton's method to square root `

std := load('std')

log := std.log
f := std.format
each := std.each

` higher order function that returns a root finder
	with the given degree of precision threshold `
makeNewtonRoot := threshold => (
	` tail call optimized root finder `
	find := (n, previous) => (
		g := guess(n, previous)
		offset := g * g - n
		offset < threshold :: {
			true -> g
			false -> find(n, g)
		}
	)

	` initial guess is n / 2 `
	n => find(n, n / 2)
)

guess := (target, n) => (n + target / n) / 2

` eight degrees of precision chosen arbitrarily, because
	ink prints numbers to 8 decimal digits`
root := makeNewtonRoot(0.00000001)

each([2, 81, 1000], n => (
	log(f('root of {{ n }} is {{ sqrt }}', {
		n: n,
		sqrt: root(n)
	}))
))
