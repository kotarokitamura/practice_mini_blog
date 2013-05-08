# coding: utf-8
require 'rubygems'
require 'rspec'
require 'mysql2'
require File.expand_path(File.dirname(__FILE__) + "/../../models/blog.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/comment.rb") 
require File.expand_path(File.dirname(__FILE__) + "/../../models/connect_db.rb") 

describe Blog do
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

  context 'with select query request' do
    it 'should be return not nil when select all blog contents' do
      blog_contents = Blog.select_all_blogs 
      blog_contents.should_not be_nil
    end 
  end
end

describe Comment do
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

  context 'whit posted within a day or not' do
    it 'should be return ture when the comment posted within a day' do 
      @comment.created_at = Time.now
      @comment.should be_created_new
    end
    
    it 'should be return false when the comment posted before over a day' do 
      @comment.created_at = Time.now - Comment::SECONDS_OF_DAY
      @comment.should_not be_created_new
    end
  end
end

