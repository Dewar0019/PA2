#Dewar Tan PA2-Movies Assignment 
#Due 9/11/2015


#For evaluation/Testing of the Predict algorithm from the MovieData class
class MovieTest
#2D Array will initialized to MovieTest in the form of [[user_id, movie_id, rating, predictive_score]]
	def initialize(results)
		@results = results
	end

#Calculates the average/mean of the given input of all results
	def mean
		average = 0.0
		for i in 0..@results.size-1
			average += @results[i][3] #grabs the predictive_score
		end
	 return average/@results.size
	end

#Calculation for std deviation between predictive scores
	def stddev
		average = mean
		variance = 0.0
		for i in 0..@results.size-1
			variance += (@results[i][3]-average) ** 2 
		end
	return variance/@results.size
	end

#Calculation for root mean square
	def rms
		sum = 0.0
		for i in 0..@results.size-1
			sum += (@results[i][3]) ** 2
		end
		return Math.sqrt(sum/@results.size)
	end

#returns the array that it was passed
	def to_a
		return @results
	end	
end