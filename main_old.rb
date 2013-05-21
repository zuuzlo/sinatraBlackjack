require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  if session[:player_name]
    #progress to the game
  else
    redirect '/new_player'
  end
end

class Player
  # include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    #@cards = []
  end

  def show_flop
    show_hand
  end

end

class Blackjack < Sinatra::Base

  
  
  def initialize
    @player = Player.new("Player 1")

  end

  def set_player_name

    get '/' do
      erb :username
    end

    post '/game' do
      player.name = params['username']
      "Hello #{@name}"
      #@num_of_decks = params['numdecks']
    end
  end

  def start
    set_player_name
  end

end


game = Blackjack.new
game.start










