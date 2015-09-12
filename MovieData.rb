#Dewar Tan PA2-Movies Assignment 
#Due 9/11/2015

require "./MovieTest.rb"

#Takes in a movie data file and performs analyses based on user ratings from 1-5
class MovieData < MovieTest
	attr_accessor :movie_rankings, :test_set
	def initialize(path, test_set= [])
		if test_set == []
		@movie_rankings = load_data("#{path}/u.data") #rankings of the movies sorted from most reviewed at index 0
		@test_set = test_set
		else
		@movie_rankings = load_data("#{path}/#{test_set}.base") #rankings of the movies sorted from most reviewed at index 0
		@test_set = load_data("#{path}/#{test_set}.test") #loads in test file
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
		return movie_reviews[0][1]["#{user_id}"].to_f #grabs the rating the user gave it
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

#Calculates the average rating from the movie and also the median rating
	def popularity(movie_id)
		average_rating = 0
		selected_movie = @movie_rankings.select {|hash_movie_id, value| hash_movie_id == movie_id} #Selects movie from hash with same ID
		user_reviews = selected_movie[0][1] #Grabs the inner nested hash with all the user reviews for that movie
		user_reviews.each do |user_id, score|
			average_rating += score.to_i
		end
		return (average_rating.to_f/user_reviews.length)
	end

#Predictive function to determine what rating the user will give a movie they've not seen
	def predict(user_id, movie_id)
		user_evidence_score = user_rating_versus_average("#{user_id}")
		movie_evidence_score = movie_rating_versus_average("#{movie_id}")
		user_closest_score = movie_evidence_score.min_by { |user_id, user_adjusted_rating| (user_adjusted_rating - user_evidence_score).abs }[0] #grabs the user_id with the most similar adjusted ratings
		return rating("#{user_closest_score}", "#{movie_id}")
	end

#For all the movies the user has seen how does typically rate them versus the average
#weighted more heavily on user_rating if it differs from average to exemplify succinct preferences
	def user_rating_versus_average(user_id)
		score = 0.0
		list_of_movies = movies(user_id)
			weighted = 0
			list_of_movies.each do |movie|
				user_rating = rating("#{user_id}", movie)
				average_rating= popularity(movie)
				if (average_rating-user_rating).abs >= 1.5
					weighted += 1
					score += user_rating*20 #weighted more heavily indicating user preference over average/common ratings
				else
					score += average_rating
				end
			end
			return score / (weighted + list_of_movies.length).to_f
	end

#Examines all the users that have rated the movie alters their ratings based on unique preferences of other movies
	def movie_rating_versus_average(movie_id)
		find_similar_user = Hash.new()
		list_of_viewers = viewers("#{movie_id}")
		list_of_viewers.each do |user|
			find_similar_user[user] = user_rating_versus_average(user).to_f #Inferring how other people would have rated this movie based on others they've seen
		end
		return find_similar_user
	end


#Returns a similary score of 0.0 to 1.0 based on their movie/ratings
	def similarity(user1, user2)
			ratings_similarity = 0
			filtered_similarities = @movie_rankings.select {|movies, reviews| reviews.has_key?(user1) && reviews.has_key?(user2)} #grabs all the movies that user 1 and 2 have seen
			filtered_similarities.each do |movie|
				user_1_rating = movie[1]["#{user1}"].to_i
				user_2_rating = movie[1]["#{user2}"].to_i
				ratings_similarity += (user_1_rating-user_2_rating).abs.to_f #Differences in user ratings
			end
			return (ratings_similarity/filtered_similarities.length).to_f/5 #compare user difference in rating similarity out of 5
		end


#Finds and sorts a list of users whom are most similar to given user based on review of same movies and similariy score
	def most_similar(checking_user)
			list_similar_users = Hash.new() #List for similar users
			filtered_results = @movie_rankings.select {|key, value| value.has_key?(checking_user)} #Selects all the movies in which user has also reviewed
			filtered_results.each do |movie, users|		
				users.each do |user_id, rating|
					list_similar_users[user_id] = similarity(checking_user, user_id)
				end
			end
			return list_similar_users.sort_by{|user_id, score| -score} #sorts the occurences of similarity	
		end


#runs the predictive algorithim above k times and defaults to size of k if not specified
	def run_test(k= @test_set.size)
		prediction_results = []
		for i in 0...k do
			movie_id = @test_set[i][0]
			user_id =  @test_set[0][1].first[0] #Grabs the first rating from my nested data structure hash
			rating =  @test_set[0][1].first[1] 
			prediction_results.push([user_id, movie_id, rating, predict(movie_id, user_id)])
		end
		return MovieTest.new(prediction_results)
	end


end

#Short test below to see if it works

z = MovieData.new("ml-100k", :u3)

now = Time.now()
# a = z.run_test(5)
# puts "mean: #{a.mean}"
# puts "stddev: #{a.stddev}"
# puts "rms: #{a.rms}"
# print "array: #{a.to_a}\n"

# b = z.run_test(10)
# puts "mean: #{b.mean}"
# puts "stddev: #{b.stddev}"
# puts "rms: #{b.rms}"
# print "array: #{b.to_a}\n"

# c = z.run_test(20)
# puts "mean: #{c.mean}"
# puts "stddev: #{c.stddev}"
# puts "rms: #{c.rms}"
# print "array: #{c.to_a}\n"

d = z.run_test(80)
puts "mean: #{d.mean}"
puts "stddev: #{d.stddev}"
puts "rms: #{d.rms}"
print "array: #{d.to_a}\n"

puts "Time Taken to Complete:"
puts Time.now() - now





 



