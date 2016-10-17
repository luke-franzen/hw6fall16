class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movie_arr = Tmdb::Movie.find(string)
      
      if movie_arr == nil
        movie_arr = []
        return movie_arr
        
      else
        hash_arr = movie_arr.each.map{|x| {:tmdb_id => x.id, :title => x.title, :release_date => x.release_date} }
        
        ratings_arr = hash_arr.each.map {|x| x[:rating] = 
                if (Tmdb::Movie.releases(x[:tmdb_id])["countries"].select {|y| y["iso_3166_1"] == "US"}) == []
                    "NR"
                else
                    rating_arr = Tmdb::Movie.releases(x[:tmdb_id])["countries"].select {|y| y["iso_3166_1"] == "US"}
                    rating = rating_arr.select {|z| z["iso_3166_1"] == "US" and z["certification"] != ""}
                    if (rating == [])
                      "NR"
                    else
                      rating[0]["certification"]
                    end
                end
                
                ; x}
    
        sleep(10)
        return ratings_arr
      end
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
                  rating_arr = Tmdb::Movie.releases(id_string)["countries"].select {|y| y["iso_3166_1"] == "US"}
                  rating = rating_arr.select {|z| z["iso_3166_1"] == "US" and z["certification"] != ""}
                  if (rating == [])
                    "NR"
                  else
                    rating[0]["certification"]
                  end
              end
    sleep(1)
    Movie.create!(:title => title, :release_date => release_date, :rating => rating)
  end

end