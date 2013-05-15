# create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id));
class Comment < Content
  BODY_MAX_LENGTH = 50
  attr_accessor :blog_id
  UPDATABLE = [:id, :blog_id, :body, :created_at]
  self.contents_unit = 2
  self.sort_colomn = "created_at"

  #-----------------------------
  # instance methods
  #-----------------------------
  def save_query_string
    "INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')"
  end

end

