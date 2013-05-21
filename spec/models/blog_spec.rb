# coding: utf-8
ENV['RACK_ENV'] = "test"
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
  PARAMS_ID = 1

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
      @blog.title = "bbb"
      @blog.body = "a" * (Blog::BODY_MAX_LENGTH ) + "a"
      @blog.should be_body_over_limit
    end

    it "should return false when title has under #{Blog::BODY_MAX_LENGTH} charactors in English" do
      @blog.title = "bbb"
      @blog.body = "a" * (Blog::BODY_MAX_LENGTH ) 
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
      @blog.title = "い"
      @blog.body = "あ" * (Blog::BODY_MAX_LENGTH ) + "あ"
      @blog.should be_body_over_limit end

    it "should return false when title has under #{Blog::BODY_MAX_LENGTH} charactors in Japanese" do
      @blog.title = "い"
      @blog.body = "あ" * (Blog::BODY_MAX_LENGTH ) 
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
    ONE_CONTENT = 1
    before do 
      @client = ConnectDb.get_client
      @client.query("create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));") 
      fixture_data = [['title1','body1'],['title2','body2'],['title2.5','body2.5'],['title3','body3']]
      @blog_data = []
      fixture_data.each do |title,body|
        @client.query("INSERT INTO blogs (title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')")
        @blog_data << {:title => title, :body => body}
      end
            
    end

    it 'should select_all_blogs and match all fixture data'  do 
      all_blogs = Blog.contents_paginate(PARAMS_ID)
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
      page_number = (@blog_data.count + ONE_CONTENT).quo(Blog.contents_unit)
      last_blog = Blog.contents_paginate(page_number.ceil).last
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

  context 'with using paginate module' do
    PAGE_ONE = 1
    before do 
      @client = ConnectDb.get_client
      @client.query("create table blogs (id INT UNSIGNED NOT NULL AUTO_INCREMENT,title TEXT, body TEXT, created_at DATETIME, updated_at DATETIME,primary key(id));") 
      fixture_data = [['title1','body1'],['title2','body2'],['title3','body3'],['title4','body4'],['title5','body5']]
      @blog_data = []
      fixture_data.each do |title,body|
        @client.query("INSERT INTO blogs (title,body,created_at,updated_at) VALUES ('#{title}','#{body}','#{Time.now}','#{Time.now}')")
        @blog_data << {:title => title, :body => body}
      end
    end

    it 'should get correct page number' do
      Blog.count_contents.should == @blog_data.count      
    end

    it 'should get content match page' do
      blogs = Blog.contents_paginate(PAGE_ONE)
      blogs.each_with_index do |blog, i|
        blog.title.should == @blog_data[i][:title]
      end
      blogs.last.should_not == @blog_data.last[:title]
    end

    it 'should check the page has next content or not' do
      Blog.contents_unit = 3 
      Blog.has_previous?(PAGE_ONE).should be_true
      Blog.has_previous?(@blog_data.count/Blog.contents_unit + PAGE_ONE).should be_false
    end

    after do
      @client.query("drop table blogs")
    end
  end

end

