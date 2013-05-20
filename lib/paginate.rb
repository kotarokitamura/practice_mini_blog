module Paginate
  FIRST_CONTENT = 1
  BLOG_CONTENTS_UNIT = 10
  COMMENT_CONTENTS_UNIT = 1000

  def self.included(base)
    base.extend ClassMethod
  end
  
  module ClassMethod
    def contents_paginate(page_number)
      page_number = FIRST_CONTENT if page_number.nil?
      contents_offset = BLOG_CONTENTS_UNIT * page_number.to_i - BLOG_CONTENTS_UNIT 
      get_contents("SELECT * FROM blogs ORDER BY updated_at DESC LIMIT #{BLOG_CONTENTS_UNIT}  OFFSET #{contents_offset}")
    end
    
    def contents_limited(blog)
      get_contents("SELECT * FROM comments WHERE blog_id=#{blog.id} ORDER BY created_at DESC LIMIT #{COMMENT_CONTENTS_UNIT}")
    end

    def get_contents(query_str)
      objs = []
      ConnectDb.get_client.query(query_str).each do |row|
        obj = self.new
        objs << obj.set_params({:id => row["id"], :title => row["title"], :body => row["body"], :created_at => row["created_at"], :updated_at => row["updated_at"]})
      end
      objs 
    end
  
    def count_contents
      ConnectDb.get_client.query("SELECT COUNT(*) FROM blogs").first["COUNT(*)"]
    end

    def has_previous?(page_num)
      count_contents.to_i > page_num.to_i * BLOG_CONTENTS_UNIT  
    end
  end
end
