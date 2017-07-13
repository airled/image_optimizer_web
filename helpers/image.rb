require 'securerandom'
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
    when 'fit'   then fit_image
    when 'fill'  then fill_image
    when 'scale' then scale_image
    end
    ImageOptimizer.new(@path, quality: @quality, quiet: true, level: 3).optimize
    calculate_percentage
    true
  end

  private

  def fit_image
    image = MiniMagick::Image.new(@path)
    return if (@width == '' && @height == '') ||
              (@width.to_i == image.width && @height.to_i == image.height)
    new_width = @width.empty? ? image.width : @width
    new_height = @height.empty? ? image.height : @height
    image.resize("#{new_width}x#{new_height}")
  end

  def fill_image
    image = MiniMagick::Image.new(@path)
    return if (@width == '' && @height == '') ||
              (@width.to_i == image.width && @height.to_i == image.height)
    scale_x = @width.to_i / image.width.to_f
    scale_y = @height.to_i / image.height.to_f
    resizing = scale_x > scale_y ? "#{scale_x * image.width}" : "x#{scale_y * image.height}"
    image.resize(resizing)
    image.crop("#{@width}x#{@height}+0+0")
  end

  def scale_image
    image = MiniMagick::Image.new(@path)
    return if @scale.empty?
    new_width = image.width * @scale.to_i / 100
    image.resize(new_width.to_s)
  end

  def calculate_percentage
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
