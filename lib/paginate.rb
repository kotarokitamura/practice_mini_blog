module Paginate
  require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  include PaginateCondition 
  FIRST_CONTENT_ID = 1
  attr_accessor :page_number
  def content_paginate(page_number=FIRST_CONTENT_ID)
    objs = []
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit} OFFSET #{contents_offset}").each do |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    objs
  end

  def sorted_all_contents
    sort_objs = []
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC ").each do |row|
      sort_obj = self.new
      sort_objs << sort_obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    sort_objs
  end
  
  def first_content
    first_objs = []
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn}=(SELECT MAX(#{self.sort_colomn}) FROM #{self.name.downcase}s)").each do |row|
      obj = self.new
      first_objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    first_objs.first
  end

  def last_content
    last_objs = []
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn}=(SELECT MIN(#{self.sort_colomn}) FROM #{self.name.downcase}s)").each do |row|
      obj = self.new
      last_objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    last_objs.first
  end

  def previous_page?(content)
    content.id != first_content.id
  end

  def next_page?(content)
    content.id != last_content.id 
  end 

  def previous_show_page?(content)
    previous_objs = []
    current_data = content.updated_at
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} < '#{current_data}' ORDER BY #{self.sort_colomn} DESC LIMIT 1").each do |row|
      obj = self.new
      previous_objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    @previous_obj = previous_objs.first
  end

  def next_show_page?(content)
    next_objs = []
    current_data = content.updated_at
    p current_data
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} > '#{current_data}' ORDER BY #{self.sort_colomn} LIMIT 1").each do |row|
      obj = self.new
      next_objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    @next_obj = next_objs.first
  end

end
