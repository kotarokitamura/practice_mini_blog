# create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id));
require File.dirname(__FILE__) + '/content.rb'
class Comment < Content
  BODY_MAX_LENGTH = 50
  @table_name = 'comments'
  def self.select_all_comments(params)
    comments = []
    ConnectDb.get_client.query("SELECT * FROM #{@table_name} WHERE blog_id='#{params[:id]}'").each do |row|
      comment = Comment.new
      comments << comment.set_params({:id => row["id"] ,:blog_id => row["blog_id"],:body => row["body"], :created_at => row["created_at"]})
    end
    comments
  end

  def save_valid? 
    @query_info = "INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{id}')"
    super
  end

  def check_all_valid?
    @message << "Comment is empty" if body_empty?
    @message << "Comment has under #{BODY_MAX_LENGTH} charactors" if body_over_limit?
    super
  end
  
  def body_over_limit?
    body.length > BODY_MAX_LENGTH
  end 

end

