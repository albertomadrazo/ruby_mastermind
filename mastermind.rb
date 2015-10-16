require_relative "Board"
require_relative "Validate"

def play mode
	mode =mode[0].upcase
	board = Board.new()
	validate = Validate.new()	

	if mode == 'G'
		20.times do
			puts
			board.print_sets
			puts
			letters_set = validate.validate_input	

			bulls, cows = board.get_bulls_and_cows letters_set	

			board.played_sets << [{:letters_set=>letters_set, :bulls=>bulls, :cows=> cows}]
			
			if bulls == 4
				system("clear")
				letters_set.each{|x| print x + "  "}
				puts
				puts "You've won the game!"
				system(exit)
			end	
			puts
			system("clear")
		end	
	elsif mode == 'M'
		30.times do |turno|
			system("clear")

			puts "Turno: #{turno+1}"
			computer_guess = board.computer_guess
			puts
			computer_guess.each {|color| print color + "   "}
			puts
			puts
			puts "How's my guess?"
			print "Bulls: "
			bulls = gets.chomp.to_i
			print "Cows: "
			cows = gets.chomp.to_i
			
			board.played_sets << {:letters_set=>computer_guess, :bulls=> bulls, :cows=>cows, :val=>(board.evaluate_set bulls, cows, computer_guess)}
			board.discarded_sets << computer_guess
			#bulls, cows = board.get_bulls_and_cows computer_guess
			if bulls == 4
				puts "I've won the game!!!"
				system(exit)
			end
		end
	end

	board
end


def main
	puts "***   MASTERMIND   ***"
	puts "Do you want to (G)uess or (M)ake the puzzle?"
	mode = gets.chomp
	
	system("clear")

	board = play mode

	puts
	print "Sorry, you've lost."
	puts "The correct set is"
	board.random_set.each{|x| print x + "    "}
	puts
end

main
