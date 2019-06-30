` ink fizzbuzz implementation `

log := s => out(s + '
')

` fizzes or buzzes one number `
fb := n => (
    [n % 3, n % 5] :: {
        [0, 0] -> log('FizzBuzz')
        [0, _] -> log('Fizz')
        [_, 0] -> log('Buzz')
        _ -> log(string(n))
    }
)

` fizzbuzz up to max `
fizzbuzz := max => (
    helper := (n, max) => (
        n :: {
            max -> fb(n)
            _ -> (
                fb(n)
                helper(n + 1, max)
            )
        }
    )
    helper(1, max)
)

fizzbuzz(100)
