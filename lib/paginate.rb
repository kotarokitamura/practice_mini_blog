module Paginate
  FIRST_CONTENT = 1
  BLOG_CONTENTS_UNIT = 10
  COMMENT_CONTENTS_UNIT = 1000
 
  def self.content_paginate(page_number)
    page_number = FIRST_CONTENT if page_number.nil?
    contents_offset = BLOG_CONTENTS_UNIT * page_number.to_i - BLOG_CONTENTS_UNIT 
    "SELECT * FROM blogs ORDER BY updated_at DESC LIMIT #{BLOG_CONTENTS_UNIT}  OFFSET #{contents_offset}"
  end

  def self.contents_limited(id_str)
    "SELECT * FROM comments WHERE blog_id=#{id_str} ORDER BY created_at DESC LIMIT #{COMMENT_CONTENTS_UNIT} "
  end

  def self.count_contents
    ConnectDb.get_client.query("SELECT COUNT(*) FROM blogs").first["COUNT(*)"]
  end

  def self.has_previous?(page_num)
    count_contents.to_i > page_num.to_i * BLOG_CONTENTS_UNIT  
  end

end
