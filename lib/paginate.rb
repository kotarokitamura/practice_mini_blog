module Paginate
  require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  include PaginateCondition 
  FIRST_CONTENT_ID = 1
  attr_accessor :page_number
  def content_paginate(page_number=FIRST_CONTENT_ID)
    objs = []
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit} OFFSET #{contents_offset}").each do  |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"]})
    end
    objs
  end

  def previous_page?(content)
    first_content = ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s where #{self.sort_colomn}=(select max(#{sort_colomn}) from #{self.name.downcase}s)").first 
    content.id != first_content["id"] 
  end

  def next_page?(content)
    last_content = ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s where #{self.sort_colomn}=(select min(#{sort_colomn}) from #{self.name.downcase}s)").first
    content.id != last_content["id"] 
  end 
end
