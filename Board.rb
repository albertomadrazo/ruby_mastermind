class Board
	attr_accessor :random_set, :played_sets, :colors, :position_hash, :discarded_sets

	def initialize
		@shuffle_this_set_only = false # Different random for many ocassions.
		@played_sets = []
		@colors_to_guess = 4
		@@colors = ["A", "B", "C", "D", "E", "F"]
		@@colors_hash = {:A=>1, :B=>1, :C=>1, :D=>1, :E=>1, :F=>1}
		@position_hash = [
			{:a=>1,:b=>1,:c=>1,:d=>1,:e=>1,:f=>1},
			{:a=>1,:b=>1,:c=>1,:d=>1,:e=>1,:f=>1},
			{:a=>1,:b=>1,:c=>1,:d=>1,:e=>1,:f=>1},
			{:a=>1,:b=>1,:c=>1,:d=>1,:e=>1,:f=>1},
		]
		@random_set = randomize_letters
		@@max_set_val = 0
		@discarded_sets = []
	end

	def computer_guess

		different_set = false
		
		until different_set

			set = randomize_letters
			set = randomize_positions set

			unless @discarded_sets.include? set
				different_set = true
			end

		end
	
		set
	end

	def randomize_letters

		colors_set = []
		set_to_randomize = []	

		@@colors_hash.each do |k, v|
			if v > 0
				f = v 
			else 
				f = 1
			end
			f.times do |x|
				set_to_randomize << k.to_s
			end 
		end		
	
		@colors_to_guess.times do
			@@colors = set_to_randomize.clone
			colors_set << @@colors[Random.rand(@@colors.length)]
		end

		if @shuffle_this_set_only

			colors_set = @final_guess.shuffle

		end
		colors_set				
	end


	def randomize_positions set_to_randomize

		colors_set = []
		in_position = []
		valid_letter = false

		4.times do |index|
			@position_hash[index].each do |k, v|
				if set_to_randomize.include?(k.upcase.to_s)
					v.times do
						in_position << k.upcase.to_s
					end
				end
			end
			in_position.shuffle
			i = 0
			until valid_letter
				i += 1
				letter_to_insert = in_position.sample

				if i == 400
					letter_to_insert = "A"
				end

				if set_to_randomize.include?(letter_to_insert)
					colors_set[index] = letter_to_insert
					valid_letter = true
					set_to_randomize.delete_at(set_to_randomize.find_index(letter_to_insert))
				end
			end
			valid_letter = false
			in_position = []
		end
		
		colors_set
	end


	def equivalence number
		number = number.to_i
		case number
		when 0..2
			number = number
		when 3
			number = 8
		when 4
			number = 11
		when 10..12
			number -= 5
		when 13
			number = number
		when 20
			number -= 3
		when 21
			number -= 12			
		when 22
			number = 15
		when 30
			number = 10
		end
		number
	end

	# Here letters are evaluated and assigned a value so they appear more
	# or less times depending on the frequency.
	def evaluate_set bulls, cows, guess
		val = (bulls*10)+(cows)
		num = equivalence val
		max = false

		if num > @@max_set_val
			@@max_set_val = num
			max = true
		end

		@@colors_hash.map do |k, v|
			if max
				if guess.include? k.to_s
					if (@@colors_hash[k] + num) > 15
						@@colors_hash[k] = 15
					else 
						@@colors_hash[k] += num
					end
				end
			else
				if guess.include? k.to_s
					if (v - num) > 1
						@@colors_hash[k] -= 3
					end
				end
			end
			
		end

		# aumentar solo en la posicion en que estaba cada letra
		guess.each_with_index do |value, index|
			if max == true
				if (@position_hash[index][value.downcase.to_sym] + num) > 15
					@position_hash[index][value.downcase.to_sym] = 15
				else
					@position_hash[index][value.downcase.to_sym] += num
				end
			elsif max == false
				if (@position_hash[index][value.downcase.to_sym] - num) > 1
					@position_hash[index][value.downcase.to_sym] -= 3
				end
			end
		end

		# delete letters that are not present
		case val
		when 0
			guess.each do |x| 
				@@colors.delete(x)
				@@colors_hash.delete(x.to_sym)
			end

		when 4
			guess.each_with_index do |v,x|
				@position_hash[x].delete(v.downcase.to_sym)
			end

			@shuffle_this_set_only = true
			@final_guess = guess.clone

			remove_letters_from_hash guess

		when 13, 22 # cuando 4, ademas de cortar, cortar la letra en la posicion
			@shuffle_this_set_only = true
			@final_guess = guess.clone

			remove_letters_from_hash guess

		when 1, 10 # en elimina, meterle una letra y despues dos letras
			elimina guess

		when 2, 11, 20
			elimina2 guess

		when 3, 12, 21, 30
			elimina3 guess
		#when 1..3, 10..12, 20, 21, 30
		#	elimina guess
		else
		end

		@@max_set_val = num
		val
	end
	


	def elimina3 guess
		set_to_trash =[]

		to_discard =guess.permutation.to_a
		to_discard.each do |x|
			unless @discarded_sets.include?(x)
				@discarded_sets << x
				File.open("posi.txt", "w"){|file| file.write(@discarded_sets)}
			end
		end
	end

	def elimina2 guess
		set_to_trash = []

		guess.each_with_index do |value1, index1|
			temp_guess = guess.clone
			@@colors.each_with_index do |value2, index2|
				temp_guess[index1] = value2
				to_discard = temp_guess.permutation.to_a
				to_discard.each do |x|
					unless @discarded_sets.include?(x)
						@discarded_sets << x
						File.open("posi.txt", "w"){|file| file.write(@discarded_sets)}
					end
				end
			end
		end
	end


	def elimina guess
		
		mega_array = []

		(0...guess.length).step(2).each do |x1|
			num_temp = guess.clone
			@@colors.each do |x2|
				num_temp[x1] = x2
				@@colors.each do |x3|
					num_temp[x1+1]= x3
					mega_array << num_temp.clone
				end
			end
		end
		
		mega_array.each do |x|
			unless @discarded_sets.include?(x)
				@discarded_sets << x
			end
		end

	end


	def remove_letters_from_hash guess

		#Removes useless letters from @position_hash
		to_remove = @@colors.clone

		guess.each do |z|
			to_remove.delete(z)
		end
		to_remove.each do |x|
			@position_hash.each_with_index do |value, index|
				@position_hash[index].delete(x.downcase.to_sym)
			end
		end
		
		# and from @@colors_hash
		@@colors = guess.clone
		@@colors_hash.each do |k, v| 
			unless guess.include? k.to_s
				@@colors_hash.delete(k)
			end
		end
	end


	def get_bulls_and_cows player_set
		bulls = 0
		cows = 0
		pending_cows = 0
		temp_set = @random_set.clone
		
		@colors_to_guess.times do |x|

			rand_set_index = @random_set.index(player_set[x])
			if @random_set.include?(player_set[x]) and @random_set[x] != player_set[x]
				if random_set[rand_set_index] != player_set[rand_set_index]
					cows += 1
					temp_set[rand_set_index] = "-"
				else
					pending_cows += 1
				end
			end

			if temp_set.include?(player_set[x]) and temp_set[x] == player_set[x]
				temp_set[x] = "-"
				bulls += 1
			end
		end

		if pending_cows > 0
			temp_set.length.times.each do |x|
				temp_set_index = temp_set.index(player_set[x])


				if temp_set.include?(player_set[x]) and temp_set[x] != player_set[x]
			   			temp_set[temp_set_index] = "-"
						cows += 1
				end
			end
		end

		puts
		player_set.each{|x| print x + "   "}
		puts

		return bulls, cows
	end

	def print_sets val=0
		@played_sets.each do |x, y|
			x[:letters_set].each {|z| print z + "  "}
			puts
			print "--> #{x[:bulls]} bulls - #{x[:cows]} cows."
			puts "     set value - #{x[:val]}" if x[:val]
			puts
		end
	end
end