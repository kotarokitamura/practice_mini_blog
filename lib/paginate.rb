module Paginate
  BLOG_SORT_COLUMN = 'updated_at'
  BLOG_CONTENTS_UNIT = 10
  COMMENT_SORT_COLUMN = 'created_at'
  COMMENT_CONTENTS_UNIT = 1000

  def self.included(base)
    base.extend ClassMethod
  end
  
  module ClassMethod
    def contents_paginate(page_number,obj = nil)
      page_number =  page_number.nil? ? 1 : page_number.to_i 
      contents_offset = BLOG_CONTENTS_UNIT * page_number.to_i - BLOG_CONTENTS_UNIT  
      query_str = "SELECT * FROM #{self.name.downcase}s "
      query_str += obj.nil? ? "ORDER BY #{BLOG_SORT_COLUMN} DESC LIMIT #{BLOG_CONTENTS_UNIT} OFFSET #{contents_offset}" : " WHERE #{obj.class.name.downcase}_id=#{obj.id} ORDER BY #{COMMENT_SORT_COLUMN} DESC LIMIT #{COMMENT_CONTENTS_UNIT} " 
      {:data => get_contents(query_str),:page_info => {:has_next => has_next?(page_number) ,:current_page => page_number ,:has_previous => has_previous?(page_number) }} 
    end

    def get_contents(query_str)
      objs = []
      ConnectDb.get_client.query(query_str).each do |row|
        obj = self.new
        objs << obj.set_params({:id => row["id"],:blog_id => row["blog_id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
      end
      objs 
    end
  
    def count_contents
      ConnectDb.get_client.query("SELECT COUNT('id') FROM #{self.name.downcase}s ").first["COUNT('id')"]
    end
 
    def has_next?(page_num)
      page_num != 1
    end

    def has_previous?(page_num)
      count_contents.to_i > page_num.to_i * BLOG_CONTENTS_UNIT
    end
  end
end
