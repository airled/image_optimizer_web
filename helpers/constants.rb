module Constants
  KEEP_FOLDER_PATH = File.expand_path('../../public/downloads/', __FILE__).freeze
  JPG_SIGNATURE    = [255, 216, 255]
  PNG_SIGNATURE    = [137, 80, 78]
  GIF_SIGNATURE    = [71, 73, 70]
end
