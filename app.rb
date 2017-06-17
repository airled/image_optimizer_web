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
  Dir.mkdir("./public/downloads/#{dirname}")
  params[:images].each do |file_param|
    next unless Helpers::Determiner.image?(file_param[:filename])
    File.open("./public/downloads/#{dirname}/#{file_param[:filename]}", 'wb') do |file|
      file << File.read(file_param[:tempfile])
    end
  end
  quality = params[:quality].nil? ? 80 : params[:quality].to_i
  Helpers::Optimizer.new(quality).optimize_all_in_dir("./public/downloads/#{dirname}")
  Helpers::Packer.new.pack_all_in_dir("./public/downloads/#{dirname}")
  Helpers::Cleaner.new.clean_dir("./public/downloads/#{dirname}")
  body "http://#{request.env['HTTP_HOST']}/downloads/#{dirname}/optimized.zip"
end
