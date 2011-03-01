require 'sinatra/base'
require 'erb'

class Charts < Sinatra::Base
  get '/' do
    erb :"index.html"
  end
end
