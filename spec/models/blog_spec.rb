# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/spec_helper.rb") 

describe Blog do
  include SettingDb 

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
    before(:all) do 
      create_table
      fixture :blog
    end

    it 'should select_all_blogs and match all fixture data'  do 
      Blog.contents_paginate(1)[:data].each_with_index do |blog,count|
        blog.title.should == @contents_data[count][:title]
        blog.body.should == @contents_data[count][:body]
      end 
    end
 
    it 'should select_blog one and match it' do 
      blog = Blog.select_one(1)
      blog.title.should == @contents_data.first[:title]
      blog.body.should == @contents_data.first[:body]
    end

    it 'should insert new blog' do 
      @blog.title = 'title51'
      @blog.body = 'body51'
      @blog.should be_save_valid
      page_number = (@contents_data.count + 1).quo(Blog::BLOG_CONTENTS_UNIT).ceil
      last_blog = Blog.contents_paginate(page_number)[:data].last
      last_blog.title.should == @blog.title
      last_blog.body.should == @blog.body
    end

    it 'should update blog information' do 
      @blog.id = 1 
      @blog.title = 'hogehoge'
      @blog.body = 'foofoo'
      @blog.should be_save_valid
      first_blog = Blog.select_one(1)
      first_blog.title.should == @blog.title 
      first_blog.body.should == @blog.body
    end 

    it 'should delete first blog' do
      Blog.delete_one(1)
      Blog.select_one(1).should be_nil
    end
  end

  context 'with using paginate module' do
    before(:all) do 
      fixture :blog
    end

    it 'should get correct page number' do
      Blog.count_contents.should == @contents_data.count      
    end

    it 'should get content match page' do
      blogs = Blog.contents_paginate(1)[:data]
      blogs.each_with_index do |blog, i|
        blog.title.should == @contents_data[i][:title]
        blog.body.should == @contents_data[i][:body]
      end
    end

    it 'should check the page has next content or not' do
      Blog.has_previous?(1).should be_true
      Blog.has_previous?(@contents_data.count/Blog::BLOG_CONTENTS_UNIT + 1).should be_false
    end
  end
end

