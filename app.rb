require 'sinatra'
require 'mini_magick'
require 'image_optimizer'
require 'securerandom'
require 'fileutils'
require_relative './helpers/helpers'

helpers Helpers

get '/' do
  erb :form
end

post '/upload' do
  dirname = "#{Time.now.to_i}-#{SecureRandom.hex}"
  Helpers::Carrier.new.save(dirname, params)
  quality = params[:quality].nil? ? 80 : params[:quality].to_i
  Helpers::Optimizer.new(quality).optimize_all_in_dir(dirname)
  Helpers::Packer.new.pack_all_in_dir(dirname)
  Helpers::Cleaner.new.clean_dir(dirname)
  body "http://#{request.env['HTTP_HOST']}/downloads/#{dirname}/optimized.zip"
end
