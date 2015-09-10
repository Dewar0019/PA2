class MovieData
	attr_accessor :movie_rankings, :test_set
	def initialize(path, test_set= [])
		if test_set == []
		@movie_rankings = load_data("#{path}/u.data") #rankings of the movies sorted from most reviewed at index 0
		@test_set = test_set
		else
		@movie_rankings = load_data("#{path}/#{test_set}.base") #rankings of the movies sorted from most reviewed at index 0
		@test_set = load_data("#{path}/#{test_set}.test")
		end	
	end

#loads the data from the movie data file
	def load_data(path)
		movie_data = open(path) 
		movie_ratings = Hash.new() #data structure for storing the ratings
		movie_data.each_line do |data_line|
			split_data = data_line.split(' ')
			user_id = split_data[0]
			movie_id = split_data[1]
			user_rating = split_data[2]
			if movie_ratings[movie_id] == nil #sorts by movie_ID first in hash
				movie_ratings[movie_id] = Hash.new() #creates new has for storing ratings by user_ID
				movie_ratings[movie_id][user_id] = user_rating #stores the rating number from the user
			else
				movie_ratings[movie_id][user_id] = user_rating #movie has already been reviewed once before
			end
		end
		@movie_rankings = movie_ratings.sort_by {|movies, reviews| -reviews.length} #Creates the ranking list by sorting the most popular/Most reviewed movies
	end

	#Returns the rating user gave a movie
	def rating(user_id, movie_id)
		movie_reviews = @movie_rankings.select {|movie, user| movie == "#{movie_id}"} #Grabs the movie
		return movie_reviews[0][1]["#{user_id}"] #grabs the rating the user gave it
	end

	def predict(user_id, movie_id)
	end

#Returns an array of movies the user has rated
	def movies(user_id)
		movies_seen = []
		user_filtered_results = @movie_rankings.select{|movie, user| user.has_key?("#{user_id}")} #Filters out all the movies that have user given rating
		user_filtered_results.each do |movie|
			movie_id = movie[0]
			movies_seen.push(movie_id) 
		end
		return movies_seen
	end

#Returns an array of users that have rated the movie
	def viewers(movie_id)
		users_seen = []
		movie_filtered_results = @movie_rankings.select{|movie, user| movie == "#{movie_id}"}[0][1] #Grabs the nested hash of all the user ratings
		movie_filtered_results.each do |user, rating|
			users_seen.push(user)
		end
		return users_seen
	end


z = MovieData.new("ml-100k")







