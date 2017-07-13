require 'mini_magick'
require 'image_optimizer'
require 'addressable'
require_relative './constants'

class Image
  attr_reader :url
  attr_reader :percentage

  def initialize(params)
    @tempfile   = params[:file][:tempfile]
    @file_name  = params[:file][:filename]
    @old_size   = @tempfile.size
    @quality    = params[:quality].to_s.empty? ? 80 : params[:quality].to_i
    @width      = params[:width].to_s.strip
    @height     = params[:height].to_s.strip
    @scale      = params[:scale].to_s.strip
    @resize     = params[:resize]
    @path       = nil
    @url        = nil
    @percentage = nil
  end

  def image?
    signature = @tempfile.read(3).bytes
    (signature == Constants::JPG_SIGNATURE && @file_name.match(/.+\.jpe?g\z/i)) ||
    (signature == Constants::PNG_SIGNATURE && @file_name.match(/.+\.png\z/i)) ||
    (signature == Constants::GIF_SIGNATURE && @file_name.match(/.+\.gif\z/i))
  end

  def save
    dir_name = "#{Time.now.to_i}-#{SecureRandom.uuid}"
    Dir.mkdir("#{Constants::KEEP_FOLDER_PATH}/#{dir_name}")
    @path = "#{Constants::KEEP_FOLDER_PATH}/#{dir_name}/#{@file_name}"
    File.open(@path, 'wb') { |file| file << File.read(@tempfile) }
    @url = "/downloads/#{dir_name}/#{Addressable::URI.escape(@file_name)}"
    @path
  end

  def optimize!
    case @resize
    when 'fit'
      image = MiniMagick::Image.new(@path)
      unless (@width == '' && @height == '') || (@width == image.width.to_s && @height == image.height.to_s)
        new_width = @width.empty? ? image.width : @width
        new_height = @height.empty? ? image.height : @height
        MiniMagick::Image.new(@path).resize("#{new_width}x#{new_height}")
      end
    when 'fill'
      image = MiniMagick::Image.new(@path)
      unless (@width == '' && @height == '') || (@width == image.width.to_s && @height == image.height.to_s)
        scale_x = @width.to_i / image.width.to_f
        scale_y = @height.to_i / image.height.to_f
        resizing = scale_x > scale_y ? "#{scale_x * image.width}" : "x#{scale_y * image.height}"
        image.resize(resizing)
        image.crop("#{@width}x#{@height}+0+0")
      end
    when 'scale'
      image = MiniMagick::Image.new(@path)
      unless @scale.empty?
        new_width = image.width * @scale.to_i / 100
        MiniMagick::Image.new(@path).resize(new_width.to_s)
      end
    end
    ImageOptimizer.new(@path, quality: @quality, quiet: true, level: 3).optimize
    calculate_pecentage
    true
  end

  private

  def calculate_pecentage
    percent = (get_current_size - @old_size) * 100 / @old_size
    @percentage =
      if percent.positive?
        {percent: "+#{percent}", color: 'warning'}
      else
        {percent: percent.to_s, color: 'success'}
      end
  end

  def get_current_size
    File.size(@path)
  end
end
