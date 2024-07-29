Gem::Specification.new do |s|
	s.name        = "symcalc"
	s.version     = "1.0.0"
	s.summary     = "Symbolic mathematics and calculus in Ruby"
	s.description = <<~EOF
	SymCalc adds symbolic mathematics and calculus to your code. Create, evaluate and differentiate mathematical functions with a single method call.
	EOF
	s.authors     = ["Kyryl Shyshko"]
	s.email       = "kyryloshy@gmail.com"
	s.files       = ["lib/symcalc.rb"]
	s.homepage    = "https://symcalc.site/ruby"
	s.license     = "Apache-2.0"
	s.required_ruby_version = ">= 3.0.0"
	s.metadata = {
		"changelog_uri" => "https://symcalc.site/ruby/changelog",
		"documentation_uri" => "https://symcalc.site/ruby/docs",
		"homepage_uri" => "https://symcalc.site/ruby",
		"source_code_uri" => "https://github.com/symcalc/symcalc-ruby",
		"bug_tracker_uri" => "https://github.com/symcalc/symcalc-ruby/issues"
	}
end
