require 'zip'

module Helpers

  class Determiner
    def self.image?(name)
      name.split('.').last.match(/jpe?g|png/i)
    end
  end

  class Carrier
    def save(dirname, params)
      Dir.mkdir("./public/downloads/#{dirname}")
      params[:images].each do |file_param|
        next unless Determiner.image?(file_param[:filename])
        File.open("./public/downloads/#{dirname}/#{file_param[:filename]}", 'wb') do |file|
          file << File.read(file_param[:tempfile])
        end
      end
    end
  end

  class Optimizer
    def initialize(quality = 80)
      @quality = quality
    end

    def optimize_all_in_dir(dir_path)
      entries = Dir.entries(dir_path).reject! { |x| x == '.' || x == '..' }
      entries.each do |entry|
        full_path = dir_path + '/' + entry
        ImageOptimizer.new(full_path, quality: @quality).optimize if Determiner.image?(full_path)
      end
    end
  end

  class Packer
    def pack_all_in_dir(dir_path)
      entries = Dir.entries(dir_path).reject! { |x| x == '.' || x == '..' }
      Zip::File.open("#{dir_path}/optimized.zip", Zip::File::CREATE) do |zipfile|
        entries.each { |entry| zipfile.add(entry, dir_path + '/' + entry) }
      end
    end
  end

  class Cleaner
    def clean_dir(dir_path)
      entries = Dir.entries(dir_path).reject! { |x| x == '.' || x == '..' || x.include?('zip') }
      entries.each do |entry|
        full_path = dir_path + '/' + entry
        File.delete(full_path)
      end
    end
  end

end
