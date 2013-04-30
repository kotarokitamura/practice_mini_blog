# create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));
class Blog
  UPDATABLE = [:id, :title, :body]
  TITLE_MAX_LENGTH = 50
  BODY_MAX_LENGTH= 300
  #-----------------------------
  # class methods
  #-----------------------------
  def self.select_blog(params)
    blogs = []
    ConnectDb.get_client.query("SELECT * FROM blogs WHERE id='#{params[:id]}'").each do |row|
      blog = Blog.new
      blogs << blog.set_params({:id => row["id"], :title => row["title"], :body => row["body"]})
    end
    blogs.first
  end

  def self.select_all_blogs
    blogs = []
    ConnectDb.get_client.query("SELECT * FROM blogs").each do |row|
      blog = Blog.new
      blogs << blog.set_params({:id => row["id"], :title => row["title"], :body => row["body"]})
    end
    blogs
  end

  def self.delete_one(params)
    idstr = params["id"]
    ConnectDb.get_client.query("DELETE FROM blogs WHERE id=#{idstr}")
  end

  #-----------------------------
  # instance methods
  #-----------------------------
  
  attr_accessor :id,:title,:body
  attr_reader :error_message


  def save_valid?
    if valid?
      client = ConnectDb.get_client
      q = if new_record?
        "INSERT INTO blogs(title,body) VALUES ('#{title}','#{body}')"
      else
        "UPDATE blogs SET title='#{title}',body='#{body}' WHERE id=#{id}"
      end
      client.query(q)
      true
    else
      false
    end
  end

  def new_record?
    self.id.nil?
  end

  def valid?
    message = []
    message << "title should not be blank." if title == ""
    message << "body should not be blank." if body == ""
    message << "word count of title should be under 50 capitals" if title.length > TITLE_MAX_LENGTH 
    message << "word count of body should be under 300 capitals" if body.length > BODY_MAX_LENGTH
    if message == []
      true
    else
      @error_message = message.join('<br>')
      false
    end
  end

  def set_params(params)
    params.each do |key, val|
      next unless UPDATABLE.include?(key.to_sym)
      self.send(key.to_s+"=", val)
    end
    self
  end

end
