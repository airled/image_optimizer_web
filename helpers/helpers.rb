require 'zip'
require 'addressable'
require 'securerandom'
require_relative './constants'

module Helpers
  class Zipper
    def self.zip_from(links)
      zip_path = "#{Constants::KEEP_FOLDER_PATH}/#{SecureRandom.hex}.zip"
      Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
        links.each do |link|
          image_path = Addressable::URI.unescape(link).gsub('/downloads/', '')
          zipfile.add(image_path.split('/').last, "#{Constants::KEEP_FOLDER_PATH}/#{image_path}")
        end
      end
      zip_path
    end
  end
end
