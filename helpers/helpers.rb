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
    def initialize(params)
      @quality = params[:quality].to_s.empty? ? 80 : params[:quality].to_i
      @width = params[:width].to_s.strip
      @height = params[:height].to_s.strip
      @resize = params[:resize]
    end

    def optimize_all_in_dir(dir_name)
      Dir.entries("#{KEEP_FOLDER_PATH}/#{dir_name}").each do |entry|
        next if ['.', '..'].include?(entry)
        full_path = "#{KEEP_FOLDER_PATH}/#{dir_name}/#{entry}"
        case @resize
        when 'fit'
          image = MiniMagick::Image.new(full_path)
          unless (@width == '' && @height == '') || (@width == image.width.to_s && @height == image.height.to_s)
            new_width = @width.empty? ? image.width : @width
            new_height = @height.empty? ? image.height : @height
            MiniMagick::Image.new(full_path).resize("#{new_width}x#{new_height}")
          end
        when 'fill'
          image = MiniMagick::Image.new(full_path)
          unless (@width == '' && @height == '') || (@width == image.width.to_s && @height == image.height.to_s)
            scale_x = @width.to_i / image.width.to_f
            scale_y = @height.to_i / image.height.to_f
            if scale_x > scale_y
              image.resize("#{scale_x * image.width}")
            else
              image.resize("x#{scale_y * image.height}")
            end
            image.crop("#{@width}x#{@height}+0+0")
          end
        end
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
