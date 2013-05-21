require 'rubygems'
require 'pry'
require 'sinatra'

set :sessions, true

def cards
 #deck
  suits = %w(H D C S)
  values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  @deck = suits.product(values).shuffle!
  #deal cards
  @player_cards = []
  @dealer_cards = []
  session[:player_cards_image] = []
  session[:dealer_cards_image] = []
  session[:dealer_display?] = true
end

def deal
  @player_cards << @deck.pop
  @dealer_cards << @deck.pop
  @player_cards << @deck.pop
  @dealer_cards << @deck.pop
end
 def to_image(cards)
    card_out = []
    cards.each do | suit, value |
      case suit
      when "H" 
        card_suit = "h"
      when "D"
        card_suit = "h"
      when "C"
        card_suit = "c"
      when "S"
        card_suit = "s"
      end

      case value
      when "J"
        card_value = "j"
      when "Q"
        card_value = "q"
      when "K"
        card_value = "k"
      when "A"
        card_value = "1"
      else
        card_value = value
      end
      card_out << "#{card_suit}#{card_value}.png"
    end
   card_out
  end

def cards_to_images
   @player_cards.each do | card |
    session[:player_cards_image] = to_image(@player_cards)
  end
  @dealer_cards.each do | card |
    session[:dealer_cards_image] = to_image(@dealer_cards)
  end
 
end


get '/' do
  cards
  deal
  cards_to_images
  
  if session[:player_name]
    
    redirect '/game'
  else
    
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :username
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  session[:dealer_display?] = true
  redirect '/game'
end

get '/game' do
  erb :game
end

post '/toggle' do
  if session[:dealer_display?]
    session[:dealer_display?] = false
  else
    session[:dealer_display?] = true
  end
    

  redirect '/game'
    
end