# coding: utf-8
require 'rubygems'
require 'rspec'
require 'mysql2'
require 'yaml'
require File.expand_path(File.dirname(__FILE__) + "/../../models/content.rb")
require File.expand_path(File.dirname(__FILE__) + "/../../models/blog.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/comment.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/connect_db.rb") 

describe Blog do
 FIRST_BLOG_ID = 1
  before do
    @blog = Blog.new
  end
  context 'with title and body have many pattern' do

    it 'should return true when title is empty' do
      @blog.title = ""
      @blog.body = "aaa"
      @blog.should be_title_empty
    end

    it 'should return true when body is empty' do
      @blog.title = "aaa"
      @blog.body = ""
      @blog.should be_body_empty
    end   
    
    it "should return true when title has over #{Blog::TITLE_MAX_LENGTH} charactors in English" do
      @blog.title = "a" * (Blog::TITLE_MAX_LENGTH) + "a"
      @blog.body = "bbb"
      @blog.should be_title_over_limit
    end

    it "should retrun false when title has under  #{Blog::TITLE_MAX_LENGTH} charactors in English" do
      @blog.title = "a" * (Blog::TITLE_MAX_LENGTH) 
      @blog.body = "bbb"
      @blog.should_not be_title_over_limit
    end


    it "should return true when title has over #{Blog::BODY_MAX_LENGTH} charactors in English" do
      @blog.body = "a" * (Blog::BODY_MAX_LENGTH ) + "a"
      @blog.title = "bbb"
      @blog.should be_body_over_limit
    end

    it "should return false when title has under #{Blog::BODY_MAX_LENGTH} charactors in English" do
      @blog.body = "a" * (Blog::BODY_MAX_LENGTH ) 
      @blog.title = "bbb"
      @blog.should_not be_body_over_limit
    end

    it "should return true when title has over #{Blog::TITLE_MAX_LENGTH} charactors in Japanese" do
      @blog.title = "あ" * (Blog::TITLE_MAX_LENGTH) + "あ"
      @blog.body = "い"
      @blog.should be_title_over_limit
    end

    it "should retrun false when title has under  #{Blog::TITLE_MAX_LENGTH} charactors in Japanese" do
      @blog.title = "あ" * (Blog::TITLE_MAX_LENGTH) 
      @blog.body = "い"
      @blog.should_not be_title_over_limit
    end


    it "should return true when title has over #{Blog::BODY_MAX_LENGTH} charactors in Japanese" do
      @blog.body = "あ" * (Blog::BODY_MAX_LENGTH ) + "あ"
      @blog.title = "い"
      @blog.should be_body_over_limit end

    it "should return false when title has under #{Blog::BODY_MAX_LENGTH} charactors in Japanese" do
      @blog.body = "あ" * (Blog::BODY_MAX_LENGTH ) 
      @blog.title = "い"
      @blog.should_not be_body_over_limit
    end
  end

  context 'whit posted within a day or not' do
    it 'should return true when the article posted within a day' do
      @blog.created_at = Time.now
      @blog.should be_created_new
    end
    
    it 'should retrun false when the article posted before over a day' do 
      @blog.created_at = Time.now - Blog::SECONDS_OF_DAY 
      @blog.should_not be_created_new
    end 
  end

  context 'with blogs query' do
    before do 
      @client = ConnectDb.get_client
      @client.query("create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));") 
      fixture_data = [['title1','body1'],['title2','body2'],['title3','body3']]
      @blog_data = []
      fixture_data.each do |title,body|
        @client.query("INSERT INTO blogs (title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')")
        @blog_data << {:title => title, :body => body}
      end
            
    end

    it 'should select_all_blogs and match all fixture data'  do 
      all_blogs = Blog.select_all_contents
      all_blogs.each_with_index do |blog,count|
        blog.title.should == @blog_data[count][:title]
        blog.body.should == @blog_data[count][:body]
      end 
    end
 
    it 'should select_blog one and match it' do 
      blog = Blog.select_one(FIRST_BLOG_ID)
      blog.title.should == @blog_data.first[:title]
      blog.body.should == @blog_data.first[:body]
    end

    it 'should insert new blog' do 
      @blog.title = 'title4'
      @blog.body = 'body4'
      @blog.should be_save_valid
      last_blog = Blog.select_all_contents.last
      last_blog.title.should == @blog.title
      last_blog.body.should == @blog.body
    end

    it 'should update blog information' do 
      @blog.id = FIRST_BLOG_ID
      @blog.title = 'hogehoge'
      @blog.body = 'foofoo'
      @blog.should be_save_valid
      first_blog = Blog.select_one(FIRST_BLOG_ID)
      first_blog.title.should == @blog.title 
      first_blog.body.should == @blog.body
    end 

    it 'should delete first blog' do
      Blog.delete_one(FIRST_BLOG_ID)
      Blog.select_one(FIRST_BLOG_ID).should be_nil
    end
  
    after do
      @client.query("drop table blogs")
    end
  end
end

describe Comment do
 BLOG_ID_OF_COMMENT = 1
 FIRST_COMMENT_ID = 1
  before do 
    @comment = Comment.new
  end 

  context 'with comment body has many pattern' do
    it 'should be retrun true when body is empty' do 
      @comment.body = ""
      @comment.should be_body_empty 
    end   
    
    it 'should be return false when body is not empty' do
      @comment.body = "aaa"
      @comment.should_not be_body_empty
    end

    it "should be return true when body has over #{Comment::BODY_MAX_LENGTH} in English" do
      @comment.body = "a" * (Comment::BODY_MAX_LENGTH) + "a" 
      @comment.should be_body_over_limit
    end
 
    it "should be return true when body has over #{Comment::BODY_MAX_LENGTH} in Japanese" do
      @comment.body = "あ" * (Comment::BODY_MAX_LENGTH) + "あ"
      @comment.should be_body_over_limit
    end

    it "should be return false when body has under #{Comment::BODY_MAX_LENGTH} in English" do
      @comment.body = "a" * (Comment::BODY_MAX_LENGTH) 
      @comment.should_not be_body_over_limit
    end

    it "should be return false when body has under #{Comment::BODY_MAX_LENGTH} in Japanese" do 
      @comment.body = "あ" * (Comment::BODY_MAX_LENGTH) 
      @comment.should_not be_body_over_limit
    end
  end 

  context 'with posted within a day or not' do
    it 'should be return ture when the comment posted within a day' do 
      @comment.created_at = Time.now
      @comment.should be_created_new
    end
    
    it 'should be return false when the comment posted before over a day' do 
      @comment.created_at = Time.now - Comment::SECONDS_OF_DAY
      @comment.should_not be_created_new
    end
  end

  context 'with comments query' do
    before do
      @blog = Blog.new
      @blog.id = BLOG_ID_OF_COMMENT
      @client = ConnectDb.get_client
      @client.query("create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id))")
      fixture_data = [['comment1-1','1'],['comment2-1','2'],['comment1-2','1']]
      @comment_data = []
      fixture_data.each do |body,blog_id|
        @client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')")
        @comment_data << ({:body => body,:blog_id => blog_id})
      end
    end
    
    it 'should get all comments same blog_id' do 
      Comment.select_all_contents(@blog) do |comment| 
        comment.blog_id.should  == BLOG_ID_OF_COMMENT 
      end 
    end

    it 'should delete comment' do 
      Comment.delete_one(FIRST_COMMENT_ID)
      Comment.select_all_contents(@blog).each do |comment|
        comment.id.should_not == FIRST_COMMENT_ID
      end
    end
 
    after do 
      @client.query("drop table comments") 
    end

  end 
end

