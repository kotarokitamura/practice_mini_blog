# create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));
require File.expand_path(File.dirname(__FILE__) + "/../lib/paginate.rb")
class Blog < Content
  TITLE_MAX_LENGTH = 50
  attr_accessor :title,:updated_at
  UPDATABLE = [:id, :title, :body, :created_at, :updated_at]
  #-----------------------------
  # instance methods
  #-----------------------------

  def save_query_string
    "INSERT INTO blogs(title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')"
  end

  def update_query_string
    "UPDATE blogs SET title='#{title}',body='#{body}',updated_at='#{Time.now}'  WHERE id=#{id}"
  end

  def check_valid_and_set_error_message
    self.error_message << "title should not be blank." if title_empty?
    self.error_message << "word count of title should be under #{TITLE_MAX_LENGTH} capitals" if title_over_limit?
  end

  def title_empty?
    title == ""
  end

  def title_over_limit?
    title.length > TITLE_MAX_LENGTH
  end

end
