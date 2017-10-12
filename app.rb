require 'sinatra'
require 'sinatra/reloader'

require_relative 'master'

get '/' do
  'Put this in your pipe & smoke it!'
end
