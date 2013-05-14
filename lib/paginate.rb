module Paginate
  require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  include PaginateCondition 
  FIRST_CONTENT_ID = 1
  attr_accessor :page_number
  def content_paginate(page_number=FIRST_CONTENT_ID)
    @objs = []
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit} OFFSET #{contents_offset}").each do |row|
      obj = self.new
      @objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    @objs
  end

  def sorted_all_contents
    sort_objs = []
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC ").each do |row|
      sort_obj = self.new
      sort_objs << sort_obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    sort_objs
  end

  def previous_page?(content)
    content.id != sorted_all_contents.first.id
  end

  def next_page?(content)
    content.id != sorted_all_contents.last.id 
  end 
end
