require 'sinatra'
require 'securerandom'
require 'json'
require_relative './helpers/helpers'
require 'uri'

set :server, :puma

helpers Helpers

get '/' do
  slim :form
end

post '/upload' do
  halt 400 unless Helpers::Determiner.image?(params)
  dirname = "#{Time.now.to_i}-#{SecureRandom.uuid}"
  comparator = Helpers::Comparator.new(params)
  Helpers::Carrier.new(params).save(dirname)
  Helpers::Optimizer.new(params).optimize_all_in_dir(dirname)
  diff = comparator.compare(dirname)
  content_type :json
  {link: URI.escape("/downloads/#{dirname}/#{params[:file][:filename]}"), diff: diff}.to_json
end

post '/get_zip' do
  halt 400 if params[:links].to_s.strip.empty?
  begin
    links = JSON.parse(params[:links])
    raise unless links.is_a?(Array)
  rescue
    halt 400
  end
  zip = Helpers::Ziper.new.zip_from(links)
  send_file zip
end

