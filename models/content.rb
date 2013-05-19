require File.expand_path(File.dirname(__FILE__) + "/../lib/paginate.rb")  
class Content
  SECONDS_OF_DAY = 86400
  BODY_MAX_LENGTH = 300
  attr_accessor :id, :body, :created_at, :error_message
  include Paginate
  #----------------------------
  # class methods
  #-----------------------------

  def self.select_all(page_number)
    objs = [] 
    #query_str = Paginate.content_paginate(page_number)
    ConnectDb.get_client.query(@query_str).each do |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    objs
  end

  def self.select_one(id_str)
    objs = []
    query_str = Paginate.contents_limited(id_str)
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
    if check_all_valid?
      ConnectDb.get_client.query(new_record? ? save_query_string : update_query_string)
      true
    else
      false
    end
  end

  def created_new?
    Time.now - created_at < SECONDS_OF_DAY
  end

  def set_params(params)
    params.each do |key,val|
      next if val.nil?
      next unless self.class::UPDATABLE.include?(key.to_sym)
      self.send(key.to_s+"=",val)
    end
    self
  end

  def check_all_valid?
    self.error_message = []
    check_valid_and_set_error_message
    self.error_message << "word count of title should be under #{self.class::BODY_MAX_LENGTH} capitals" if body_over_limit?
    self.error_message << "body should not be empty" if body_empty?
    self.error_message == []
  end

  def body_empty?
    body == ""
  end

  def body_over_limit?
    body.length > self.class::BODY_MAX_LENGTH
  end

  def check_valid_and_set_error_message
  end

end

