# create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));
class Blog
  UPDATABLE = [:id, :title, :body]
  TITLE_MAX_LENGTH = 50
  BODY_MAX_LENGTH = 300
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

  def initialize 
    @message = []
  end

  def save_valid?
    if check_all_valid?
      client = ConnectDb.get_client
      q = if new_record?
        "INSERT INTO blogs(title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')"
      else
        "UPDATE blogs SET title='#{title}',body='#{body}',updated_at='#{Time.now}'  WHERE id=#{id}"
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

  def check_all_valid?
    @message << "title should not be blank." if title_empty?
    @message << "body should not be empty" if body_empty?
    @message << "word count of title should be under #{TITLE_MAX_LENGTH} capitals" if title_over_limit? 
    @message << "word count of title should be under #{BODY_MAX_LENGTH} capitals" if body_over_limit? 
    if @message == []
      true
    else
      @error_message = @message.join('<br>')
      false
    end
  end

  def title_empty?
    title == ""
  end

  def body_empty?
    body == ""
  end

  def title_over_limit?
    title.length > TITLE_MAX_LENGTH
  end

  def body_over_limit?
    body.length > BODY_MAX_LENGTH
  end

  def set_params(params)
    params.each do |key, val|
      next unless UPDATABLE.include?(key.to_sym)
      self.send(key.to_s+"=", val)
    end
    self
  end

end
