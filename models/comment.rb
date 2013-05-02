# create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id));
class Comment
  UPDATABLE = [:id, :body, :created_at]

  def self.select_all_comments(params)
    comments = []
    ConnectDb.get_client.query("SELECT * FROM comments WHERE blog_id='#{params[:id]}'").each do |row|
      comment = Comment.new
      comments << comment.set_params({:id => row["id"], :body => row["body"], :created_at => row["created_at"]})
    end
    comments
  end

  attr_accessor :id, :body, :created_at

  def save_valid?
    client = ConnectDb.get_client
    client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{created_at}','#{@id}')")
  end
  
  def set_params(params)
    params.each do |key,val|
      next unless UPDATABLE.include?(key.to_sym)
      self.send(key.to_s+"=",val)
    end
    self
  end
end

