module Paginate
  #require File.expand_path(File.dirname(__FILE__) + '/contents_unit.rb')
  #include PaginateCondition 
  FIRST_CONTENT = 1

  def content_paginate(page_number)
    page_number = FIRST_CONTENT if page_number.nil?
    contents_offset = self.contents_unit * page_number.to_i - self.contents_unit
    get_content("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit} OFFSET #{contents_offset}")
  end

  def content_limited(content)
    get_content("SELECT * FROM #{self.name.downcase}s WHERE #{content.class.name}_id=#{content.id.to_s} ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit}")
  end

  def previous_content(content)
    current_data  = content.updated_at 
    get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} < '#{current_data}' ORDER BY #{self.sort_colomn} DESC LIMIT #{FIRST_CONTENT}").first
  end

  def next_content(content)
    current_data = content.updated_at
    get_content("SELECT * FROM #{self.name.downcase}s WHERE #{self.sort_colomn} > '#{current_data}' ORDER BY #{self.sort_colomn} LIMIT #{FIRST_CONTENT}").first
  end

  def get_content(query_str)
    objs = []
    ConnectDb.get_client.query(query_str).each do |row|
      obj = self.new
      objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
    end
    objs
  end

  #####
  #
  # method for settings
  #
  ####


  def contents_unit=(limit)
    @contents_unit = limit.to_i
  end
  def contents_unit
    @contents_unit
  end

  def sort_colomn=(limit)
    @sort_colomn = limit.to_s
  end
  def sort_colomn
    @sort_colomn
  end
end
