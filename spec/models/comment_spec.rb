# coding: utf-8
ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/spec_helper.rb") 

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
      fixture_data = []
      for num in 1..2000 do
        fixture_data << ["comment#{num}",1]     
      end
      @comment_data = []
      fixture_data.each do |body,blog_id|
        @client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')")
        @comment_data << ({:body => body,:blog_id => blog_id})
      end
    end
    
    it 'should get all comments same blog_id' do 
      Comment.contents_paginate(@blog)[:data].each do |comment| 
        comment.blog_id.should  == BLOG_ID_OF_COMMENT 
      end 
    end

    it 'should delete comment' do 
      Comment.delete_one(FIRST_COMMENT_ID)
      Comment.contents_paginate(@blog)[:data].each do |comment|
        comment.id.should_not == FIRST_COMMENT_ID
      end
    end
 
    after do 
      @client.query("drop table comments") 
    end
  end 
 
  context 'with using paginate module' do 
    before do
      @blog = Blog.new
      @blog.id = BLOG_ID_OF_COMMENT
      @client = ConnectDb.get_client
      @client.query("create table comments (id INT UNSIGNED NOT NULL AUTO_INCREMENT,blog_id INT, body TEXT, created_at DATETIME, primary key(id))")
      fixture_data = []
      for num in 1..2000 do
        fixture_data << ["comment#{num}",1]     
      end
      @comment_data = []
      fixture_data.each do |body,blog_id|
        @client.query("INSERT INTO comments(body,created_at,blog_id) VALUES ('#{body}','#{Time.now}','#{blog_id}')")
        @comment_data << ({:body => body,:blog_id => blog_id})
      end
    end
   
    it 'should get contents only limited number' do
      Comment.contents_paginate(@blog)[:data].count.should == Comment::COMMENT_CONTENTS_UNIT
      Comment.contents_paginate(@blog)[:data].last.body.should_not == @comment_data.last[:body]
    end

    after do 
      @client.query("drop table comments") 
    end
  end
end
