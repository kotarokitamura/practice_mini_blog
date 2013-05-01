# coding: utf-8
require 'rubygems'
require 'rspec'
require File.expand_path(File.dirname(__FILE__) + "/../../models/blog.rb") 

describe Blog do
  before do
    @blog = Blog.new
  end

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
    @blog.should be_body_over_limit
  end

  it "should return false when title has under #{Blog::BODY_MAX_LENGTH} charactors in Japanese" do
    @blog.body = "あ" * (Blog::BODY_MAX_LENGTH ) 
    @blog.title = "い"
    @blog.should_not be_body_over_limit
  end
end

