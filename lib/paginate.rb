module Paginate
  require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  include PaginateCondition 
  FIRST_CONTENT_ID = 1
  attr_accessor :page_number 
  def content_paginate(page_number=FIRST_CONTENT_ID)
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    get_content("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit} OFFSET #{contents_offset}")
  end

  def first_content
     get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn}=(SELECT MAX(#{self.sort_colomn}) FROM #{self.name.downcase}s)").first
  end

  def last_content
     get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn}=(SELECT MIN(#{self.sort_colomn}) FROM #{self.name.downcase}s)").first
  end

  def previous_show_page(content)
    current_data = self.sort_colomn
    get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} < '#{content.updated_at}' ORDER BY #{self.sort_colomn} DESC LIMIT 1").first
  end

  def next_show_page(content)
    current_data = content.updated_at
    get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} > '#{current_data}' ORDER BY #{self.sort_colomn} LIMIT 1").first
  end

  def get_content(query_str)
    objs = []
    ConnectDb.get_client.query(query_str).each do |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    objs
  end
end
