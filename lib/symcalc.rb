# Copyright (c) 2024 Kyryl Shyshko
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# SymCalc auto simplify option
if !$SYMCALC_AUTO_SIMPLIFY
	$SYMCALC_AUTO_SIMPLIFY = true
end

# The SymCalc module
module SymCalc

class Equation
	
	def to_s
		self.display()
	end
	
	# def inspect
	# 	self.display()
	# end
	
	def display
		""
	end
	
	def coerce(other)
		[to_equation(other), self]
	end

	def *(eq)
		eq = Multiplication.new([self, to_equation(eq)])
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def /(eq)
		eq = Division.new(self, to_equation(eq))
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def +(eq)
		eq = Sum.new([self, to_equation(eq)])
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def -@()
		eq = Negate.new(self)
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def -(eq)
		eq = Sum.new([self, Negate.new(to_equation(eq))])
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def **(eq)
		eq = Power.new(self, to_equation(eq))
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
	def __derivative__(variable: nil)
		raise "No derivative function implemented for this object"
	end
	
	# Calculate the derivative of the given function
	# Accepts parameters order and variable.
	# If the function has more than one dimensional, the variable needs to be provided
	#
	# Example:
	# x = SymCalc.var("x")
	# y = SymCalc.var("y")
	# fx = x ** 2
	# fx.derivative order: 2
	#
	# fxy = x ** 2 + 3 * y
	# fxy.derivative variable: x
	#
	def derivative(order: 1, variable: nil)
		if variable == nil && self.all_variables.size < 2
			fx = self.simplify
			order.times do
				fx = fx.__derivative__
				fx = fx.simplify if $SYMCALC_AUTO_SIMPLIFY
			end
			return fx
		elsif variable == nil && self.all_variables.size > 1
			raise "Expected a variable as input for a #{self.all_variables.size}-dimensional function"
		else
			fx = self.simplify
			order.times do 
				fx = fx.__derivative__(variable: variable)
				fx = fx.simplify if $SYMCALC_AUTO_SIMPLIFY
			end
			return fx
		end
	end
	
	def __simplify__
		return self
	end
	
	# Simplifies the given function
	# Accepts no arguments
	#
	def simplify
		self.__simplify__
	end
	
	def __eval__(var_hash)
		raise "__eval__ method not implemented for this class"
	end
	
	# Evaluates the function at given variable values
	# Accepts the hash of variables and their values to evalualte the function
	#
	# Example:
	# x = SymCalc.var("x")
	# fx = x ** 2
	# puts fx.eval(x: 3)
	#
	def eval(var_hash = nil)
		var_hash = Hash.new if !var_hash
		if var_hash.values.size == 0
			result = self.__eval__(var_hash)
		elsif !var_hash.values[0].is_a?(Array)
			result = self.__eval__ var_hash
		elsif var_hash.values[0].is_a? Array
			result = []
			var_hash.values[0].size.times do |i|
				hash = var_hash.map {|k, v| [k, v[i]]}.to_h
				result << self.__eval__(hash)
			end
		end
		result
	end
	
	
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return self
	end
	
	# Returns an equation with an expression substituted for the replacement
	#
	# Example:
	# a = SymCalc.var("a")
	# f = a ** 2
	# x = SymCalc.var("x")
	# puts f.sub(a, 3 * x) # => (3 * x) ** 2
	# 
	def sub original, replacement
		eq = self.__sub__(original, replacement)
		eq = eq.simplify if $SYMCALC_AUTO_SIMPLIFY
		eq
	end
	
end

# Converts the given argument into the equation type, if not already an equation
def to_equation(eq)
	if eq.is_a? Equation
		eq
	else
		EquationValue.new(eq)
	end
end

# Implements basic numeric values as the Equation class
class EquationValue < Equation
	
	attr_accessor :value
	
	def initialize(value)
		@value = value
	end
	
	def display
		return @value.to_s
	end
	
	def __eval__ var_hash
		if @value.is_a? Integer
			return @value.to_f
		else
			return @value
		end
	end
	
	def __derivative__ variable: nil
		return EquationValue.new 0
	end
	
	def ==(value)
		@value == value
	end
	
	def all_variables
		[]
	end
	
end

# Implements the Constant class. Behaves like EquationValue when evaluating and like Variable when printing
class Constant < Equation

	attr_accessor :value, :name
	
	def initialize(name, value)
		@value = value
		@name = name
	end
	
	def display
		return @name
	end
	
	def __eval__ var_hash
		if @value.is_a? Integer
			return @value.to_f
		else
			return @value
		end
	end
	
	def __derivative__ variable: nil
		return EquationValue.new 0
	end
	
	def ==(value)
		@value == value
	end
	
	def all_variables
		[]
	end

end


# Implements the Variable class
class Variable < Equation
	
	# Create a new symbolic variable with a custom display name, and an optional fixed value
	# Accepts the display name and an optional fixed_value
	# Fixed_value works in the cases of evaluating the function
	# 
	# Example:
	# x = Variable.new "x", 5
	# fx = x ** 2
	# fx.eval  # => 25
	#
	def initialize name
		@name = name
	end
	
	def display
		return @name
	end
	
	def __eval__ var_hash
		if var_hash.keys.include?(@name.to_sym) or var_hash.keys.include?(@name.to_s)
			return (var_hash[@name.to_sym] or var_hash[@name.to_s])
		else
			raise "No value provided for #{@name.to_s} in eval"
			# return nil
		end
	end
	
	def __derivative__ variable: nil
		if variable == nil || variable == self
			return EquationValue.new 1
		else
			return to_equation(0)
		end
	end
	
	def __simplify__
		self
	end
	
	def all_variables
		return [self]
	end
end


# Implements sum operations in SymCalc
class Sum < Equation
	def initialize elements
		@elements = []
		elements.each do |eq|
			if eq.is_a? Sum
				@elements += eq.instance_variable_get(:@elements)
			else
				@elements << eq
			end
		end
	end
	
	def display
		return @elements.map{|eq| "(#{eq.display})"}.join(" + ")
	end
	
	def __eval__ var_hash
		return @elements.map{|eq| eq.eval(var_hash)}.sum
	end
	
	def __derivative__ variable: nil
		return Sum.new(@elements.map{|eq| eq.__derivative__(variable: variable)})
	end
	
	def __simplify__
		simplified = @elements.map{|eq| eq.__simplify__}		
		
		simplified.filter! do |el|
			if el.is_a? EquationValue
				next if el.value == 0
			end
			true
		end

		if simplified.size == 1
			return simplified[0]
		end
		
		return Sum.new(simplified)
	end
	
	def all_variables
		return @elements.map{|eq| eq.all_variables }.flatten.uniq
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		
		return Sum.new(@elements.map{|eq| eq.__sub__(original, replacement)})
	end
end

# Implements the subtraction operation in SymCalc
class Negate < Equation
	def initialize eq
		@eq = eq
	end
	
	def display
		return "-(#{@eq.display})"
	end
	
	def __eval__ var_hash
		return -@eq.eval(var_hash)
	end
	
	def __derivative__ variable: nil
		return -@eq.__derivative__(variable: variable)
	end
	
	def __simplify__
		return Negate.new(@eq.__simplify__)
	end

	def all_variables
		return @eq.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Negate.new(@eq.__sub__(original, replacement))
	end
end

# Implements the multiplication operation in SymCalc
class Multiplication < Equation
	def initialize elements
		@elements = []
		elements.each do |el|
			if el.is_a? Multiplication
				@elements += el.instance_variable_get(:@elements)
			else
				@elements << el
			end
		end
	end
	
	def display
		return @elements.map{|el| "(#{el.display})"}.join(" * ")
	end
	
	def __eval__ var_hash
		result = 1
		@elements.each do |el|
			result *= el.__eval__(var_hash)
		end
		result
	end
	
	def __derivative__ variable: nil
		
		sum_of_mults_arr = []
		
		@elements.size.times do |element_index|
			mult_arr = []
			
			
			mult_arr << @elements[element_index].__derivative__(variable: variable)
			
			@elements.size.times do |mult_el_index|
				if element_index == mult_el_index
					next
				end
				mult_arr << @elements[mult_el_index]
			end
			
			sum_of_mults_arr << Multiplication.new(mult_arr)
		end
		
		return Sum.new(sum_of_mults_arr)
	end
	
	def __simplify__
		
		numbers = []
		simplified = []
		
		@elements.each do |eq|
			s_eq = eq.__simplify__()
			
			if s_eq.is_a? EquationValue
				if s_eq.value == 0
					return EquationValue.new(0)
				elsif s_eq.value == 1
					next
				else
					numbers << s_eq.value
				end
			else
				simplified << s_eq
			end			
		end
		

		coeff = 1
		numbers.each {|n| coeff *= n}
		
		if coeff != 1
			simplified.insert 0, EquationValue.new(coeff)
		end
		
		if simplified.size == 1
			return simplified[0]
		end
		
		return Multiplication.new(simplified)
	end
	
	def all_variables
		return @elements.map{|el| el.all_variables}.flatten.uniq
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Multiplication.new(@elements.map{|el| el.__sub__(original, replacement)})
	end
end

# Implements the division operation in SymCalc
class Division < Equation
	
	attr_accessor :lside, :rside
	
	def initialize lside, rside
		@lside = lside
		@rside = rside
	end
	
	def display
		return "(#{@lside.display}) / (#{@rside.display})"
	end
	
	def __eval__ var_hash
		return @lside.eval(var_hash) / @rside.eval(var_hash)
	end
	
	def __derivative__ variable: nil
		# return (@lside * @rside ** (-1)).derivative(variable: variable)
		return (@lside.derivative * @rside - @lside * @rside.derivative) / (@rside ** 2)
	end
	
	def __simplify__
		@lside = @lside.__simplify__
		@rside = @rside.__simplify__
		if @lside == EquationValue.new(0)
			return EquationValue.new(0)
		else
			return self
		end
	end
	
	def == eq
		if eq.is_a? Division
			return (eq.lside == @rside) && (eq.lside == @lside)
		else
			return false
		end
	end
	
	
	def all_variables
		return (@lside.all_variables + @rside.all_variables).uniq
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return @lside.__sub__(original, replacement) / @rside.__sub__(original, replacement)
	end
end


# Implements the exp operation in SymCalc
class Exp < Equation
	
	attr_accessor :power
	
	def initialize power
		@power = to_equation(power)
	end
	
	def display
		return "exp(#{@power.display})"
	end
	
	def __eval__ var_hash
		return Math::E ** (@power.eval(var_hash))
	end
	
	def __derivative__ variable: nil
		return Exp.new(@power) * @power.derivative(variable: variable)
	end
	
	def == eq
		if eq.is_a? Exp
			return eq.power == @power
		else
			return false
		end
	end
	
	def __simplify__
		if @power.is_a? Ln
			return @power.eq
		elsif @power.is_a?(Log) && @power.base == BasicVars::E
			return @power.eq
		else
			return self
		end
	end
	
	def all_variables
		return @power.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Exp.new(@power.__sub__(original, replacement))
	end
end


# Implements the power operation in SymCalc
class Power < Equation
	
	attr_accessor :base, :power
	
	def initialize base, power
		@base = base
		@power = power
	end
	
	def display
		return "(#{@base.display})^(#{@power.display})"
	end
	
	def __eval__ var_hash
		return @base.eval(var_hash) ** @power.eval(var_hash)
	end
	
	def __derivative__ variable: nil
		# exp(@power * ln(@base)).derivative
		return @base ** @power * (@power.derivative(variable: variable)*Ln.new(@base) + @base.derivative(variable: variable)*@power/@base)
	end
	
	def == eq
		if eq.is_a? Power
			return (eq.base == @base) && (eq.power == @power)
		elsif (eq == EquationValue.new(1))
			return @power == 0
		else
			return false
		end
	end
		
	def __simplify__
		
		s_base = @base.__simplify__
		s_power = @power.__simplify__
		
		if s_power == EquationValue.new(0)
			return EquationValue.new(1)
		elsif s_power == EquationValue.new(1)
			return s_base
		elsif s_base.is_a?(EquationValue) && s_power.is_a?(EquationValue)
			computed = s_base.value ** s_power.value
			if computed.to_s.size <= 6
				return to_equation(computed)
			else
				return s_base ** power
			end
		elsif s_base.is_a?(Power)
			new_base = s_base.base
			new_power = s_base.power * s_power
			return (new_base ** new_power).__simplify__
		else
			return Power.new(s_base, s_power)
		end
		
	end
	
	def all_variables
		return (@base.all_variables + @power.all_variables).uniq
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return @base.__sub__(original, replacement) ** @power.__sub__(original, replacement)
	end
end

# Implements the sin operation in SymCalc
class Sin < Equation
	def initialize eq
		@eq = eq
	end
	
	def display
		return "sin(#{@eq.display})"
	end
	
	def __eval__ var_hash
		return Math.sin(@eq.eval(var_hash))
	end
	
	def __derivative__ variable: nil
		return Cos.new(@eq) * @eq.derivative(variable: variable)
	end
	
	def __simplify__
		return Sin.new(@eq.__simplify__)
	end
	
	def all_variables
		return @eq.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Sin.new(@eq.__sub__(original, replacement))
	end
end

# Implements the cos operation in SymCalc
class Cos < Equation
	def initialize eq
		@eq = eq
	end
	
	def display
		return "cos(#{@eq.display})"
	end
	
	def __eval__ var_hash
		return Math.cos(@eq.eval(var_hash))
	end
	
	def __derivative__ variable: nil
		return -1 * Sin.new(@eq) * @eq.derivative(variable: variable)
	end
	
	def __simplify__
		return Cos.new(@eq.__simplify__)
	end
	
	def all_variables
		return @eq.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Cos.new(@eq.__sub__(original, replacement))
	end
end


# Implements the natural logarithm operation in SymCalc
class Ln < Equation
	
	attr_accessor :eq
	
	def initialize eq
		@eq = eq
	end
	
	def display
		return "ln(#{@eq.display})"
	end
	
	def __eval__ var_hash
		return Math.log(@eq.eval(var_hash), Math::E)
	end
	
	def __derivative__ variable: nil
		return 1 / @eq * @eq.derivative(variable: variable)
	end
	
	def __simplify__
		return Ln.new(@eq.__simplify__)
	end
		
	def all_variables
		return @eq.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Ln.new(@eq.__sub__(original, replacement))
	end
end

# Implements the logarithm operation in SymCalc
class Log < Equation
	
	attr_accessor :eq, :base
	
	# Implements the logarithm operation in SymCalc
	# Accepts the base and equation arguments
	#
	# Example:
	# 
	# x = SymCalc.var("x")
	# fx = Log.new 10, x ** 2
	#
	def initialize base, eq
		@base = to_equation(base)
		@eq = to_equation(eq)
	end
	
	def display
		return "log_(#{@base.display})(#{@eq.display})"
	end
	
	def __eval__ var_hash
		return Math.log(@eq.eval(var_hash), @base.eval(var_hash))
	end
	
	def __derivative__ variable: nil
		return 1 / (Ln.new(@base) * @eq) * @eq.derivative(variable: variable)
	end
	
	def __simplify__
		return Log.new(@base.__simplify__, @eq.__simplify__)
	end
	
	def all_variables
		return (@base.all_variables + @eq.all_variables).uniq
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Log.new(@base.__sub__(original, replacement), @eq.__sub__(original, replacement))
	end
end

# Implements the absolute value operation in SymCalc
class Abs < Equation
	
	attr_accessor :eq
	
	def initialize eq
		@eq = to_equation(eq)
	end
	
	def display
		return "|#{@eq.display}|"
	end
	
	def __eval__ var_hash
		return @eq.eval(var_hash).abs
	end
	
	def __derivative__ variable: nil
		return @eq / Abs.new(@eq) * @eq.derivative(variable: variable)
	end
	
	def __simplify__
		if @eq.is_a?(Power) && @eq.power.is_a?(EquationValue) && @eq.power.value.is_a?(Numeric) && (@eq.power.value % 2 == 0)
			return @eq
		end
		self
	end
	
	def all_variables
		return @eq.all_variables
	end
	
	def __sub__ original, replacement
		return to_equation(replacement) if self == to_equation(original)
		return Abs.new(@eq.__sub__(original, replacement))
	end
end


# Basic variables that are already implemented in SymCalc and have fixed values
module Constants
	
	Pi = Constant.new "pi", Math::PI
	E = Constant.new "e", Math::E

end




# sin(equation) is the same as Sin.new(equation), just shorter
def sin(eq)
	return Sin.new(to_equation(eq))
end

# cos(equation) is the same as Cos.new(equation), just shorter
def cos(eq)
	return Cos.new(to_equation(eq))
end

# ln(equation) is the same as Ln.new(equation), just shorter
def ln(eq)
	return Ln.new(to_equation(eq))
end

# log(base, equation) is the same as Log.new(base, equation), just shorter
def log(base, eq)
	return Log.new(to_equation(base), to_equation(eq))
end

# exp(equation) is the same as Exp.new(equation), just shorter
def exp(power)
	return Exp.new(to_equation(power))
end

# var(name) is the same as Variable.new(name), just shorter
def var(name)
	Variable.new name
end

def const(name, value)
	Constant.new name, value
end

# abs(equation) is the same as Abs.new(equation), just shorter
def abs eq
	return Abs.new(to_equation(eq))
end

module_function :sin, :cos, :ln, :log, :exp, :var, :abs, :const
	
end
