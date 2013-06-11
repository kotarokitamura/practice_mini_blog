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
    insert_attr = fixture_contents["#{content}1"].keys.join(',')
    all_insert_values = []
    fixture_contents.count.times do |i|
      each_insert_values ="('" + fixture_contents["#{content}#{i+1}"].values.join("','") + "')"
      all_insert_values << each_insert_values
    end
    joined_insert_values = all_insert_values.join(',')
    @client.query("INSERT INTO #{content}s (#{insert_attr}) VALUES #{joined_insert_values}")
  end
end

