require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
   it 'should guard against invalid search terms' do
     allow(MoviesController).to receive(:search_tmdb).with("")
     post :search_tmdb, {:search_terms => ""}
     expect(response).to redirect_to('/movies')
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the search terms available to that template' do
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:search_term)).to eq('Ted')
    end
     it 'should flash no movies match when search terms yield no results' do
      post :search_tmdb, {:search_terms => 'asd;fojas;ofj'}
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to eq("No matching movies were found on TMDb")
    end
  end
  
  describe 'adding movies' do
    it 'should call the model method that creates Tmdb Movie' do
      expect(Movie).to receive(:create_from_tmdb).with("lethal")
      expect(Movie).to receive(:create_from_tmdb).with("weapon")
      expect(Movie).to receive(:create_from_tmdb).with("finding")
      post :add_tmdb, {"tmdb_movies" => {"lethal" => "1", "weapon" => "1", "finding" => "1"}}
      expect(flash[:notice]).to eq("Movies successfully added to Rotten Potatoes")
    end
    
    it 'should redirect to the index if no movies selected' do
      post :add_tmdb, {}
      expect(flash[:notice]).to eq("No movies selected")
      expect(response).to redirect_to(movies_path)
    end
    
  end
end