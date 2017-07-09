require 'sinatra'
require 'securerandom'
require 'json'
require 'addressable'
require_relative './helpers/helpers'

set :server, :puma

helpers Helpers

get '/' do
  slim :form
end

post '/upload' do
  halt 400 unless Helpers::Determiner.image?(params)
  dirname = "#{Time.now.to_i}-#{SecureRandom.uuid}"
  comparator = Helpers::Comparator.new(params)
  filename = Helpers::Carrier.new(params).save(dirname)
  Helpers::Optimizer.new(params).optimize_all_in_dir(dirname)
  diff = comparator.compare(dirname)
  diff.merge!(link: "/downloads/#{dirname}/#{Addressable::URI.escape(filename)}")
  content_type :json
  diff.to_json
end

post '/get_zip' do
  halt 400 if params[:links].to_s.strip.empty?
  begin
    links = JSON.parse(params[:links])
    raise unless links.is_a?(Array)
  rescue
    halt 400
  end
  zip = Helpers::Zipper.new.zip_from(links)
  send_file zip
end

