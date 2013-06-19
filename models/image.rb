require File.expand_path(File.dirname(__FILE__) + "/resource_property.rb")
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
    if file.has_key?("file")
      @error_message << "This file is not image" if false_extention?(file[:file][:filename])
    else
      @error_message << "file is empty" 
    end
    @error_message.empty? ? true : false
  end

  def false_extention?(filename)
    result = []
    ResourceProperty.image_extention.each do |ext|
      result <<  (/#{ext.to_s}\z/i =~ filename).nil?  
    end
    !result.include?(false)
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
