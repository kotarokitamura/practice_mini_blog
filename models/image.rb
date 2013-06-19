class Image
  attr_accessor :error_message
  
  def upload_file?(file)
    if check_image_valid?(file) 
      open(get_save_path(file[:file][:filename]),"w+b") do |dest| 
        open("#{file[:file][:tempfile].path}","r+b").each do |source|
          dest.puts source
        end
      end 
      true
    else
      false
    end
  end
  
  def get_save_path(file_name)
    File.expand_path(File.dirname(__FILE__) + "/../public/images/#{file_name}")
  end

  def check_image_valid?(file)
    @error_message = []
    @error_message << "file is empty" unless file.has_key?("file")
    @error_message.empty? ? true : false
  end

  def self.get_images
    path = File.expand_path(File.dirname(__FILE__) + "/../public/images/*")
    @images = []
    Dir.glob(path).each do |image|
      @images << image.gsub("/Users/kotarokitamura/mblog/public/","./")
    end
    @images
  end
end
