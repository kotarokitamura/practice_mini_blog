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
 
  def create_table
    `mysqldump -u root -d mblog | mysql -u root mblog_test`
  end

  def fixture(contents)
    @client = ConnectDb.get_client
    @client.query("TRUNCATE TABLE #{contents}")
    fixture_contents = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/#{contents}.yml") 
    fixture_data = []
    @contents_data = []
    if contents == :blogs 
      fixture_contents.each_with_index do |fixture,num|
        fixture_data << [fixture_contents["blog#{num+1}"]["title"],fixture_contents["blog#{num+1}"]["body"]]
      end
      blog_id = 1
      fixture_data.each do |title,body|
        @client.query("INSERT INTO blogs (id,title,body,created_at,updated_at) VALUES ('#{blog_id}','#{title}','#{body}','#{Time.now}','#{Time.now}')")
        @contents_data << {:title => title, :body => body}
        blog_id  += 1 
      end
    else
      @blog = Blog.new
      @blog.id = 1
      fixture_contents.each_with_index do |fixture,num|
        fixture_data << [fixture_contents["comment#{num+1}"]["body"],fixture_contents["comment#{num+1}"]["blog_id"]]
      end
      fixture_data.each do |body,blog_id|
        @client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')")
        @contents_data << ({:body => body, :blog_id => blog_id})
      end
    end
  end
end

