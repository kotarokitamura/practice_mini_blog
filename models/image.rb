require File.expand_path(File.dirname(__FILE__) + "/resource_property.rb")
class Image 
  attr_accessor :id,:error_message
  def folder_exist?(id)
    File.exist?("./public/images/#{id}") ? true : create_user_folder(id) 
  end
  
  def image_exist?(id)
    !Dir.glob("./public/images/#{id}/*").empty?
  end
 
  def create_user_folder(id)
    FileUtils.mkdir_p("./public/images/#{id}")
    File.exist?("./public/images/#{id}") ? true : false 
  end

  def upload_file?(params,id)
    if folder_exist?(id)  
      open(get_save_path(params,id),"w+b") do |dest| 
        open("#{params[:file][:tempfile].path}","r+b").each do |source|
          dest.puts source
        end
      end 
      true
    else
      false
    end
  end

  def get_save_path(params,id)
    File.expand_path(File.dirname(__FILE__) + "/../public/images/#{id}/#{params[:file][:filename]}")
  end


  def image_valid?(params)
    self.error_message = []
    if params.has_key?("file")
      self.error_message << "This file is not image" if false_extention?(params[:file][:filename])
    else
      self.error_message << "file is empty" 
    end
    self.error_message.empty?
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
    images = []
    Dir.glob(path).each do |image|
      images << image.gsub("/Users/kotarokitamura/mblog/public/","../../")
    end
    images
  end

  def self.delete_one(id)
    Dir.glob("./public/images/#{id}/*").each do |file|
      File.delete("#{file}")
    end
    Dir.rmdir("./public/images/#{id}") if File.exist?("./public/images/#{id}")
  end
end
