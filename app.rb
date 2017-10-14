require 'sinatra'
require 'sinatra/reloader'

require_relative 'master'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

get '/' do
  session.delete(:game)
  erb :index
end

post '/' do
  session[:game] = Game.new(params[:role])
  redirect "/#{params[:role]}"
end

get '/codebreaker' do
  @board = session[:game].master.the_board
  game = session[:game]
  if game.master.game_over?
    redirect '/game_over'
  else
    erb :codebreaker
  end
end

post '/codebreaker' do
  game = session[:game]
  colors = []
  colors << params[:first]
  colors << params[:second]
  colors << params[:third]
  colors << params[:forth]
  game.take_turn(colors)
  redirect back
end

get '/codemaker' do
  game = session[:game]
  if defined? game.master.code
    until game.master.game_over?
      game.take_turn
    end
    redirect '/game_over'
  else
    erb :codemaker
  end
end

post '/codemaker' do
  game = session[:game]
  colors = []
  colors << params[:first]
  colors << params[:second]
  colors << params[:third]
  colors << params[:forth]
  game.create_code(colors)
  redirect back
end

get '/game_over' do
  @code = session[:game].master.code
  @board = session[:game].master.the_board
  game = session[:game]
  if game.master.victory?
    @message = "The code has been broken!"
  else
    @message = "Codebreaker failed."
  end
  erb :game_over
end
