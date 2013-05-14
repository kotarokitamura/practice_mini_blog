module Paginate
  require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  include ContentsUnit 
  FIRST_CONTENT_ID = 1
  attr_accessor :page_number
  def content_paginate(page_number=FIRST_CONTENT_ID)
    objs = []
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    ConnectDb.get_client.query("SELECT * FROM #{self.name.downcase}s LIMIT #{self.contents_unit} OFFSET #{contents_offset}").each do  |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"]})
    end
    objs
  end

  def limited_select_contents
  end
end
