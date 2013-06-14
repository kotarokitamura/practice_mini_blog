class Image
  def copy_file(file)
    open("#{file[:file][:tempfile].path}","r+b").each do |source|
      open(get_save_path(file[:file][:filename]),"w+b").puts source
    end
  end
  
  def get_save_path(file_name)
    File.expand_path(File.dirname(__FILE__) + "/../uploaded_images/#{file_name}")
  end

  def self.get_images
    path = File.expand_path(File.dirname(__FILE__) + "/../uploaded_images/*")
    Dir.glob(path)
    #@images = []
    #Dir.glob(path).each do |image|
      #@images << image.gsub("/Users/kotarokitamura/mblog/","./")
    #end
  end
end
