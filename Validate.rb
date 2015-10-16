class Validate
	def validate_input
		letters_set = []
		letter = ''
		valid_letter = false
		regex = /^[a-zA-z]/
		puts "letters set: A, B, C, D, E, F"
		4.times do
			loop do
				print "Give me a VALID letter:     "
				letters_set.each{|x| print " " + x}
				puts
				letter = gets.chomp.upcase
				if letter[0] =~ regex and ["A", "B", "C", "D", "E", "F"].include?(letter[0])
					valid_letter = true
				else
					valid_letter = false
				end
				break if valid_letter == true
			end
			letters_set << letter[0]
			letters_set.map!(&:upcase)
		end
		letters_set
	end
end