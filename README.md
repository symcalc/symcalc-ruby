# SymCalc Ruby

![SymCalc Logo](/symcalc_logo.png)

[Website](https://symcalc.site/ruby)
/
[License: Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)
/
[Changelog](https://symcalc.site/ruby/changelog)
/
[Ruby](https://github.com/symcalc/symcalc-ruby)
, 
[C++](https://github.com/symcalc/symcalc-cpp)

SymCalc (which stands for **Sym**bolic **Calc**ulus) is a library that introduces mathematics to code, where you can declare, evaluate, and differentiate any possible maths function with a single call.

SymCalc allows to write readable and flexible code, adding a lot of functionality along the way, like this:
```ruby
fx = 5 * x ** 2 + sin(x)
```
Instead of hard-coded functions like this:
```ruby
def fx(x)
    5 * x ** 2 + Math.sin(x)
end
```

## Contents
- [Example](#example)
- [Basic usage](#basic-usage)
- [Install](#install-with-make)
- [Learning SymCalc](#learning-symcalc)
- [Authors](#authors)

## Example

```ruby
require 'symcalc'
include SymCalc

# SymCalc variable
x = var("x")

# SymCalc function
fx = x ** 2 * 5 - 4 * sin(exp(x))

# SymCalc derivative
dfdx = fx.derivative()

# SymCalc evaluate
value = dfdx.eval x: 5

puts value
```

## Basic usage

1. Require SymCalc:
```ruby
require 'symcalc'
include SymCalc
```

2. Define a variable:
```ruby
x = var("x")
```

3. Define a function:
```ruby
fx = x ** 2
```

4. Evaluate:
```ruby
value = fx.eval(x: 4)
# or
value = fx(x: 4)
```

5. Differentiate:
```ruby
dfdx = fx.derivative
```

6. Multi-variable!:
```ruby
x = var("x")
y = var("y")

fxy = x ** 2 - 4 * abs(y)

dfdx = fxy.derivative(variable: x)
dfdy = fxy.derivative(variable: y)
```

7. Display:
```ruby
puts fx # Prints the function
```

8. Run:
```bash
ruby main.rb
```

9. See more on the [website](https://symcalc.site/ruby)!

## Install

Run:

```bash
gem install symcalc
```

## Learning SymCalc

You can learn more about SymCalc on these resources:

- [SymCalc's Website](https://symcalc.site/ruby)
- [Intro](https://symcalc.site/ruby/intro)
- [Examples](https://symcalc.site/ruby/examples)
- [Docs](https://symcalc.site/ruby/docs)


## Authors

SymCalc is currently developed and maintaned by [Kyryl Shyshko](https://kyrylshyshko.me) ([@kyryloshy](https://github.com/kyryloshy))