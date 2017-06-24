require 'zip'

module Helpers

  KEEP_FOLDER_PATH = File.expand_path('../../public/downloads/', __FILE__).freeze

  class Determiner
    def self.image?(name)
      name.split('.').last.match(/jpe?g|png/i)
    end
  end

  class Carrier
    def initialize(params)
      @file_name = params[:file][:filename]
      @temp_file = params[:file][:tempfile]
    end

    def save(dir_name)
      Dir.mkdir("#{KEEP_FOLDER_PATH}/#{dir_name}")
      File.open("#{KEEP_FOLDER_PATH}/#{dir_name}/#{@file_name}", 'wb') do |file|
        file << File.read(@temp_file)
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
            resizing = scale_x > scale_y ? "#{scale_x * image.width}" : "x#{scale_y * image.height}"
            image.resize(resizing)
            image.crop("#{@width}x#{@height}+0+0")
          end
        end
        ImageOptimizer.new(full_path, quality: @quality).optimize if Determiner.image?(full_path)
      end
    end
  end

  class Packer
    def pack(links)
      zip_path = "#{KEEP_FOLDER_PATH}/#{SecureRandom.hex}.zip"
      Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
        links.each do |link|
          image_path = link.gsub('/downloads/', '')
          image_name = image_path.split('/').last
          zipfile.add(image_name, "#{KEEP_FOLDER_PATH}/#{image_path}")
        end
      end
      zip_path
    end
  end

end
