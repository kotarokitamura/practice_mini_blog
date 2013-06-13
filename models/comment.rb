# create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id));
class Comment < Content
  attr_accessor :blog_id
  UPDATABLE = [:id, :blog_id, :body, :created_at]
  #-----------------------------
  # instance methods
  #-----------------------------
  def save_query_string
    "INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')"
  end

  def body_over_limit?
    super(ResourceProperty.comment_body_max_length)
  end
 
  def set_params(params)
    super(params,ResourceProperty.comment_updatable)
  end
end

