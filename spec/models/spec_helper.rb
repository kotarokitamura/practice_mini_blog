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
  def create_blog_table
    @client = ConnectDb.get_client
    @client.query("create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));") 
  end

  def create_comment_table
    @client = ConnectDb.get_client
    @client.query("create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id))")
  end

  def drop_blog_table
    @client.query("drop table blogs")
  end

  def drop_comment_table
    @client.query("drop table comments")
  end
   
  def set_blogs
    create_blog_table
    fixture_blog_data = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/blogs.yml") 
    fixture_data = []
    fixture_blog_data.each_with_index do |fixture,num|
      fixture_data << [fixture_blog_data["blog#{num+1}"]["title"],fixture_blog_data["blog#{num+1}"]["body"]]
    end
    @blog_data = []
    fixture_data.each do |title,body|
      @client.query("INSERT INTO blogs (title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')")
      @blog_data << {:title => title, :body => body}
    end
  end

  def set_comments 
    @blog = Blog.new
    @blog.id = 1
    create_comment_table
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

