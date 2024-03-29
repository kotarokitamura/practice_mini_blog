require File.expand_path(File.dirname(__FILE__) + "/resource_property.rb")
require File.expand_path(File.dirname(__FILE__) + "/../lib/paginate.rb")  
class Content
  attr_accessor :id, :body, :created_at,:error_message
  include Paginate
  #----------------------------
  # class methods
  #-----------------------------

  def self.select_one(id_str)
    objs = []
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s WHERE id=#{id_str}").each do |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    objs.first
  end

  def self.delete_one(id_str)
    ConnectDb.get_client.query("DELETE FROM #{self.name.downcase}s WHERE id=#{id_str}")
  end
  #-----------------------------
  # instance methods
  #-----------------------------
  
  def new_record?
    self.id.nil?
  end

  def save_valid?
      conect_info = ConnectDb.get_client
      conect_info.query(new_record? ? save_query_string : update_query_string)
      self.id = conect_info.query('select last_insert_id ()').first["last_insert_id ()"]
  end

  def created_new?
    Time.now - created_at < ResourceProperty.second_of_day 
  end

  def set_params(params,updatable)
    params.each do |key,val|
      next if val.nil?
      next unless updatable.include?(key.to_sym)
      self.send(key.to_s+"=",val)
    end
    self
  end

  def check_all_valid?
    self.error_message = []
    check_valid_and_set_error_message
    self.error_message << "word count of title should be under #{ResourceProperty.body_max_length} capitals" if body_over_limit?
    self.error_message << "body should not be empty" if body_empty?
    self.error_message == []
  end

  def body_empty?
    body == ""
  end

  def body_over_limit?(body_max_length=nil)
    body.length > body_max_length 
  end

  def check_valid_and_set_error_message
  end

end

