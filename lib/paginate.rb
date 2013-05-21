module Paginate
  FIRST_CONTENT = 1

  def self.included(base)
    base.extend ClassMethod
  end
  
  module ClassMethod
    def contents_paginate(page_number)
      page_number = FIRST_CONTENT if page_number.nil?
      contents_offset = self.contents_unit * page_number.to_i - self.contents_unit 
      get_contents("SELECT * FROM #{self.name.downcase}s ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit}  OFFSET #{contents_offset}")
    end
    
    def contents_limited(blog)
      get_contents("SELECT * FROM #{self.name.downcase}s WHERE blog_id=#{blog.id} ORDER BY #{self.sort_colomn} DESC LIMIT #{self.contents_unit}")
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
      ConnectDb.get_client.query("SELECT COUNT(*) FROM #{self.name.downcase}s ").first["COUNT(*)"]
    end

    def has_previous?(page_num)
      count_contents.to_i > page_num.to_i * self.contents_unit 
    end

    def contents_unit=(value)
      @contents_unit = value.to_i
    end

    def contents_unit
      @contents_unit 
    end 
 
    def sort_colomn=(value)
      @sort_colomn = value
    end
 
    def sort_colomn
      @sort_colomn
    end

  end
end
