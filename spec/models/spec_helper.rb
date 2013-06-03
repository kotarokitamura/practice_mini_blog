require 'rubygems'
require 'rspec'
require 'mysql2'
require 'yaml'
require File.expand_path(File.dirname(__FILE__) + "/../../models/content.rb")
require File.expand_path(File.dirname(__FILE__) + "/../../models/blog.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/comment.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/connect_db.rb") 

ENV['RACK_ENV'] = "test"

module SettingDb
  def drop_table
    @client.query("drop table comments,blogs")
  end
   
  def set_blogs
    @client = ConnectDb.get_client
    `mysqldump -u root -d mblog | mysql -u root mblog_test`
    fixture_blog_data = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/blogs.yml") 
    fixture_data = []
    fixture_blog_data.each_with_index do |fixture,num|
      fixture_data << [fixture_blog_data["blog#{num+1}"]["title"],fixture_blog_data["blog#{num+1}"]["body"]]
    end
    @blog_data = []
    num = 1
    fixture_data.each do |title,body|
      @client.query("INSERT INTO blogs (id,title,body,created_at,updated_at) VALUES ('#{num}','#{title}','#{body}','#{Time.now}','#{Time.now}')")
      @blog_data << {:title => title, :body => body}
      num  += 1
    end
  end

  def set_comments 
    @blog = Blog.new
    @blog.id = 1
    @client = ConnectDb.get_client
    fixture_comment_data = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/comments.yml") 
    fixture_data = []
    fixture_comment_data.each_with_index do |fixture,num|
      fixture_data << [fixture_comment_data["comment#{num+1}"]["body"],fixture_comment_data["comment#{num+1}"]["blog_id"]]
    end
    @comment_data = []
    fixture_data.each do |body,blog_id|
      @client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')")
      @comment_data << ({:body => body, :blog_id => blog_id})
    end
  end
end

