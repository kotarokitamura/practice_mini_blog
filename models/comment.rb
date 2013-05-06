# create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id));
require File.dirname(__FILE__) + '/content.rb'
class Comment < Content
  COMMENT_MAX_LENGTH = 50
  @table_name = "comments"

  def self.select_all_comments(params)
    comments = []
    ConnectDb.get_client.query("SELECT * FROM comments WHERE blog_id='#{params[:id]}'").each do |row|
      comment = Comment.new
      comments << comment.set_params({:id => row["id"], :body => row["body"], :created_at => row["created_at"]})
    end
    comments
  end

  attr_accessor :id, :body, :created_at, :error_message

  def save_valid? 
    @query_info = "INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{id}')"
    super
  end

  def check_all_valid?
    @message << "Comment is empty" if comment_empty?
    @message << "Comment has under #{COMMENT_MAX_LENGTH} charactors" if comment_over_limit?
    if @message == []
      true
    else 
      self.error_message = @message.join('<br>')
      false 
    end
  end
  
  def created_new?
    Time.now - created_at < SECONDS_OF_DAY
  end

  def comment_empty?
    body == ""
  end

  def comment_over_limit?
    body.length > COMMENT_MAX_LENGTH
  end 

end

