require 'rubygems'
require 'pry'
require 'sinatra'

set :sessions, true
def varibles
  @play_status_message = {normal: "Enter Hand Bet Amount.", error: "Enter a Valid Bet Amount Lessthan Your Bankroll!"}
  $play_status_class = {normal: "alert alert-info",
    error: "alert alert-error", good: "alert alert-success", warning: "alert alert-block"}

  
  
  session[:bank_roll] = 1000 
end

def cards
 #deck
  suits = %w(H D C S)
  values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  session[:deck] = suits.product(values).shuffle!
  #deal cards

  
end

def deal
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards_image] = []
  session[:dealer_cards_image] = []
  session[:dealer_display?] = false
  session[:play_status] = "b" #b-bet, a-action, pa-play again
  session[:player_total] = 0
  session[:status_mess] = "Enter Hand Bet Amount."
  session[:status_class] = "alert alert-info"
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
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
   session[:player_cards].each do | card |
    session[:player_cards_image] = to_image(session[:player_cards])
  end
  session[:dealer_cards].each do | card |
    session[:dealer_cards_image] = to_image(session[:dealer_cards])
  end 
end

def hand_value(card_arr)
  arr = card_arr.map {|e| e[1]}
  total = 0
  arr.each do |value|
    if value == "A"
      total += 11
    elsif value.to_i == 0 #J,Q,K
      total += 10
    else
      total += value.to_i
    end
  end

  #correct for aces
  arr.select{|e| e[0] == "A"}.count.times do
    total -= 10 if total > 21
  end

  total
end

def dealer_turn
  session[:dealer_total] = hand_value(session[:dealer_cards])
  while session[:dealer_total] < 17
    session[:dealer_cards] << session[:deck].pop
    session[:dealer_total] = hand_value(session[:dealer_cards])
  end
  cards_to_images
end


get '/' do
  varibles
  cards
  deal
  
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
  redirect '/game'
end

get '/game' do
  erb :game
end

post '/bet' do
  session[:hand_bet] = params[:hand_bet].to_i
  if session[:hand_bet] <= 0 || session[:hand_bet].to_i > session[:bank_roll]
    session[:status_mess] = "Enter a Valid Bet Amount Lessthan Your Bankroll!"
    session[:status_class] = "alert alert-error"
  else
    session[:status_mess] = "Your bet: #{session[:hand_bet]}"
    session[:status_class] = "alert alert-success"
    #deal
    cards_to_images
    session[:dealer_display?] = true
    session[:play_status] = "a"
  end
  redirect '/game'
end

post '/hit' do
  if params[:hit] != nil
    session[:player_cards] << session[:deck].pop
    cards_to_images
    session[:player_total] = hand_value(session[:player_cards])
    
    if session[:player_total] > 21
      #do bust somethin redirect bust?
      redirect '/player_bust'
    else
      redirect '/game'
    end
  else
    redirect '/dealer_hit'
  end
end

get '/dealer_hit' do
  #TODO dealer hit code
  dealer_turn
  session[:dealer_display?] = false
  if session[:dealer_total] > 21 
    #TODO redirect to dealer bust player win
    session[:status_mess] = "#{session[:player_name]}, you WIN, Dealer busted and you win #{session[:hand_bet]}."
    session[:bank_roll] += session[:hand_bet].to_i
    session[:status_class] = "alert alert-success"
    session[:play_status] = "pa"
  else
    if session[:dealer_total] == session[:player_total]
      #TODO redirect to player tie
      session[:status_mess] = "#{session[:player_name]}, you TIE."
      session[:status_class] = "alert alert-block"
      session[:play_status] = "pa"
    elsif session[:dealer_total] < session[:player_total]
      #TODO redirect to player win
      session[:status_mess] = "#{session[:player_name]}, you WIN #{session[:hand_bet]}."
      session[:bank_roll] += session[:hand_bet].to_i
      session[:status_class] = "alert alert-success"
      session[:play_status] = "pa"
    else
      #TODO player lose
      session[:status_mess] = "#{session[:player_name]}, you LOSE, #{session[:hand_bet]}."
      session[:bank_roll] -= session[:hand_bet].to_i
      session[:status_class] = "alert alert-error"
      session[:play_status] = "pa"
    end
  end
  redirect '/game'
end


get '/player_bust' do
  #TODO for now just redirect to game
  cards_to_images
  session[:status_mess] = "#{session[:player_name]}, you BUSTED and lose #{session[:hand_bet]}."
  session[:bank_roll] -= session[:hand_bet].to_i
  session[:status_class] = "alert alert-error"
  session[:play_status] = "pa"
  session[:dealer_display?] = false
  redirect '/game'
end

post '/play_again' do
  if session[:deck].size < 11
    cards
  end
  deal
  redirect '/game'
end