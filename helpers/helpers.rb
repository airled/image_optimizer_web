require 'zip'

module Helpers

  KEEP_FOLDER_PATH = File.expand_path('../../public/downloads/', __FILE__).freeze

  class Determiner
    def self.image?(name)
      name.split('.').last.match(/jpe?g|png/i)
    end
  end

  class Carrier
    def save(dir_name, params)
      Dir.mkdir("#{KEEP_FOLDER_PATH}/#{dir_name}")
      params[:images].each do |file_param|
        next unless Determiner.image?(file_param[:filename])
        File.open("#{KEEP_FOLDER_PATH}/#{dir_name}/#{file_param[:filename]}", 'wb') do |file|
          file << File.read(file_param[:tempfile])
        end
      end
    end
  end

  class Optimizer
    def initialize(quality = 80)
      @quality = quality
    end

    def optimize_all_in_dir(dir_name)
      Dir.entries("#{KEEP_FOLDER_PATH}/#{dir_name}").each do |entry|
        next if ['.', '..'].include?(entry)
        full_path = "#{KEEP_FOLDER_PATH}/#{dir_name}/#{entry}"
        ImageOptimizer.new(full_path, quality: @quality).optimize if Determiner.image?(full_path)
      end
    end
  end

  class Packer
    def pack_all_in_dir(dir_name)
      Zip::File.open("#{KEEP_FOLDER_PATH}/#{dir_name}/optimized.zip", Zip::File::CREATE) do |zipfile|
        Dir.entries("#{KEEP_FOLDER_PATH}/#{dir_name}").each do |entry|
          next if ['.', '..'].include?(entry)
          zipfile.add(entry, "#{KEEP_FOLDER_PATH}/#{dir_name}/#{entry}")
        end
      end
    end
  end

  class Cleaner
    def clean_dir(dir_name)
      Dir.entries("#{KEEP_FOLDER_PATH}/#{dir_name}").each do |entry|
        next if entry == '.' || entry == '..' || entry.include?('.zip')
        File.delete("#{KEEP_FOLDER_PATH}/#{dir_name}/#{entry}")
      end
    end
  end

end
