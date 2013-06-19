class Image
  attr_accessor :id,:error_message
  def check_user_folder(id)
    File.exist?("./public/images/#{id}") ? true : create_user_folder(id) 
  end
  
  def create_user_folder(id)
    FileUtils.mkdir_p("./public/images/#{id}")
    File.exist?("./public/images/#{id}") ? true : false 
  end

  def upload_file?(params)
    if check_image_valid?(params) && check_user_folder(params[:id])  
      open(get_save_path(params),"w+b") do |dest| 
        open("#{params[:file][:tempfile].path}","r+b").each do |source|
          dest.puts source
        end
      end 
      true
    else
      false
    end
  end

  def get_save_path(params)
    File.expand_path(File.dirname(__FILE__) + "/../public/images/#{params[:id]}/#{params[:file][:filename]}")
  end

  def check_image_valid?(file)
    @error_message = []
    @error_message << "file is empty" unless file.has_key?("file")
    @error_message.empty? ? true : false
  end

  def self.get_images(id)
    path = File.expand_path(File.dirname(__FILE__) + "/../public/images/#{id}/*")
    @images = []
    Dir.glob(path).each do |image|
      @images << image.gsub("/Users/kotarokitamura/mblog/public/","../../")
    end
    @images
  end
end
