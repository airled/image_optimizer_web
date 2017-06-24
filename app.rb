require 'sinatra'
require 'mini_magick'
require 'image_optimizer'
require 'securerandom'
require 'fileutils'
require_relative './helpers/helpers'

helpers Helpers

get '/' do
  slim :form
end

post '/upload' do
  dirname = "#{Time.now.to_i}-#{SecureRandom.hex}"
  Helpers::Carrier.new(params).save(dirname)
  Helpers::Optimizer.new(params).optimize_all_in_dir(dirname)
  body "/downloads/#{dirname}/#{params[:file][:filename]}"
end

post '/get_zip' do
  halt 400 if params[:links].nil? || params[:links].to_s.strip.empty?
  links = JSON.parse(params[:links])
  zip = Helpers::Packer.new.pack(links)
  send_file zip
end
