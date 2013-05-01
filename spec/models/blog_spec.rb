require 'rubygems'
require 'rspec'
require File.expand_path(File.dirname(__FILE__) + "/../../models/blog.rb") 

describe Blog do
  TITLE_MAX_LENGTH = 50
  BODY_MAX_LENGTH = 300
  before do
    @blog = Blog.new
  end

  it 'should retrun false when title is empty' do
      @blog.title = ""
      @blog.body = "aaa"
      @blog.should_not be_valid_title_empty
  end

  it 'should return false when body is empty' do
     @blog.title = "aaa"
     @blog.body = ""
     @blog.should_not be_valid_body_empty
  end   
    
  
  it "should return false when title has over #{TITLE_MAX_LENGTH} charactors" do
    @blog.title = "a"
    TITLE_MAX_LENGTH.times do 
      @blog.title << "a"
    end
    @blog.body = "bbb"
    @blog.should_not be_valid_title_under_character_limit
  end

  it "should return false when title has over #{BODY_MAX_LENGTH} charactors" do
    @blog.body = "aaa"
    BODY_MAX_LENGTH.times do 
      @blog.body << "a"
    end
    @blog.title = "bbb"
    @blog.should_not be_valid_body_under_character_limit
  end
end

