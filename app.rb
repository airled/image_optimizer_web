require 'sinatra'
require 'json'
require_relative './helpers/helpers'
require_relative './helpers/image'

set :server, :puma

helpers Helpers

get '/' do
  slim :form
end

post '/upload' do
  image = Image.new(params)
  halt 400 unless image.image?
  image.save
  image.optimize!
  content_type :json
  image.percentage.merge!(link: image.url).to_json
end

post '/get_zip' do
  halt 400 if params[:links].to_s.strip.empty?
  begin
    links = JSON.parse(params[:links])
    raise unless links.is_a?(Array)
  rescue
    halt 400
  end
  zip = Helpers::Zipper.zip_from(links)
  send_file zip
end
