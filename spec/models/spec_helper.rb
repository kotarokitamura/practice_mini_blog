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

  def fixture(content)
    @client = ConnectDb.get_client
    @client.query("TRUNCATE TABLE #{content}s")
    fixture_contents = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/#{content}s.yml") 
    fixture_data = []
    @contents_data = []
    if content == :blog
      fixture_contents.each_with_index do |fixture,num|
        fixture_data << [fixture_contents["#{content}#{num+1}"]["id"],fixture_contents["#{content}#{num+1}"]["title"],fixture_contents["#{content}#{num+1}"]["body"],fixture_contents["#{content}#{num+1}"]["created_at"],fixture_contents["#{content}#{num+1}"]["updated_at"]]
         @insert_attr = fixture_contents["#{content}#{num+1}"].keys.join(',')
 
      end
      fixture_data.each do |id,title,body,created_at,updated_at|
        
        @insert_values ="'" + fixture_contents["#{content}#{id}"].values.join("','") + "'"
        @client.query("INSERT INTO #{content}s (#{@insert_attr}) VALUES (#{@insert_values})")
        @contents_data << {:title => title, :body => body}
      end
    else
      @blog = Blog.new
      @blog.id = 1
      fixture_contents.each_with_index do |fixture,num|
        fixture_data << [fixture_contents["#{content}#{num+1}"]["id"],fixture_contents["#{content}#{num+1}"]["blog_id"],fixture_contents["#{content}#{num+1}"]["body"],fixture_contents["#{content}#{num+1}"]["created_at"]]
         @insert_attr = fixture_contents["#{content}#{num+1}"].keys.join(',')
      end
      fixture_data.each do |id,blog_id,body,created_at|
        @insert_values ="'" + fixture_contents["#{content}#{id}"].values.join("','") + "'"
        @client.query("INSERT INTO #{content}s (#{@insert_attr}) VALUES (#{@insert_values})")
        @contents_data << ({:body => body, :blog_id => blog_id})
      end
    end
  end
end

