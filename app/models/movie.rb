class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      
      movie_arr = Tmdb::Movie.find(string)
      if !movie_arr.empty?
        puts("movie_arr has values")
      else
        puts("movie_arr is empty")
      end
      #sleep(3)
      ##call api request, then do shit with the result --> use callback or closure
      hash_arr = movie_arr.each.map{|x| {:tmdb_id => x.id, :title => x.title, :release_date => x.release_date} }
      
      if !hash_arr.empty?
        puts(hash_arr.each {|x| x[:title]})
      else
        puts("hash_arr is empty")
      end
      
      ratings_arr = hash_arr.each.map {|x| x[:rating] = 
              if (Tmdb::Movie.releases(x[:tmdb_id])["countries"].select {|y| y["iso_3166_1"] == "US"}) == []
                  "NR"
              else
                  rating = Tmdb::Movie.releases(x[:tmdb_id])["countries"].select {|y| y["iso_3166_1"] == "US"} [0]["certification"]
                  if (rating == "")
                    "NR"
                  else
                    rating
                  end
              end
              
              ; x}
      
      return ratings_arr
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id_string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    movie_deets = Tmdb::Movie.detail(id_string)
    title = movie_deets["title"]
    release_date = movie_deets["release_date"]
    rating = if (Tmdb::Movie.releases(id_string)["countries"].select {|y| y["iso_3166_1"] == "US"}) == []
                  "NR"
              else
                  rating = Tmdb::Movie.releases(id_string)["countries"].select {|y| y["iso_3166_1"] == "US"} [0]["certification"]
                  if (rating == "")
                    "NR"
                  else
                    rating
                  end
              end
    Movie.create!(:title => title, :release_date => release_date, :rating => rating)
  end

end