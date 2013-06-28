# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/spec_helper.rb") 

describe Blog do
  include SettingDb 
  let(:contents_data){
    fixture_contents = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../../spec/models/fixtures/blogs.yml")
    contents_data = []
    fixture_contents.each_with_index do |fixture,num|
      contents_data << {:id => fixture_contents["blog#{num+1}"]["id"],:title => fixture_contents["blog#{num+1}"]["title"],:body => fixture_contents["blog#{num+1}"]["body"],:created_at => fixture_contents["blog#{num+1}"]["created_at"],:updated_at => fixture_contents["blog#{num+1}"]["updated_at"]}
    end
  }



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
    
    it "should return true when title has over #{ResourceProperty.title_max_length} charactors in English" do
      @blog.title = "a" * (ResourceProperty.title_max_length) + "a"
      @blog.body = "bbb"
      @blog.should be_title_over_limit
    end

    it "should retrun false when title has under  #{ResourceProperty.title_max_length} charactors in English" do
      @blog.title = "a" * (ResourceProperty.title_max_length) 
      @blog.body = "bbb"
      @blog.should_not be_title_over_limit
    end

    it "should return true when body has over #{ResourceProperty.blog_body_max_length} charactors in English" do
      @blog.title = "bbb"
      @blog.body = "a" * (ResourceProperty.blog_body_max_length) + "a"
      @blog.should be_body_over_limit
    end

    it "should return false when body has under #{ResourceProperty.blog_body_max_length} charactors in English" do
      @blog.title = "bbb"
      @blog.body = "a" * (ResourceProperty.blog_body_max_length) 
      @blog.should_not be_body_over_limit
    end

    it "should return true when title has over #{ResourceProperty.title_max_length} charactors in Japanese" do
      @blog.title = "あ" * (ResourceProperty.title_max_length) + "あ"
      @blog.body = "い"
      @blog.should be_title_over_limit
    end

    it "should retrun false when title has under  #{ResourceProperty.title_max_length} charactors in Japanese" do
      @blog.title = "あ" * (ResourceProperty.title_max_length) 
      @blog.body = "い"
      @blog.should_not be_title_over_limit
    end

    it "should return true when body has over #{ResourceProperty.blog_body_max_length} charactors in Japanese" do
      @blog.title = "い"
      @blog.body = "あ" * (ResourceProperty.blog_body_max_length ) + "あ"
      @blog.should be_body_over_limit 
    end

    it "should return false when body has under #{ResourceProperty.title_max_length} charactors in Japanese" do
      @blog.title = "い"
      @blog.body = "あ" * (ResourceProperty.title_max_length) 
      @blog.should_not be_body_over_limit
    end
  end

  context 'whit posted within a day or not' do
    it 'should return true when the article posted within a day' do
      @blog.created_at = Time.now
      @blog.should be_created_new
    end
    
    it 'should retrun false when the article posted before over a day' do 
      @blog.created_at = Time.now - ResourceProperty.second_of_day 
      @blog.should_not be_created_new
    end 
  end

  context 'with blogs query' do
    before do 
      create_table
      fixture :blog
    end

    it 'should select_all_blogs and match all fixture data'  do 
      Blog.contents_paginate(1)[:data].count.should == ResourceProperty.blog_contents_unit 
      Blog.contents_paginate(1)[:data].each_with_index do |blog,count|
        contents_data["blog#{count+1}"]["title"].include?(blog.title).should be_true
        contents_data["blog#{count+1}"]["body"].include?(blog.body).should be_true
      end 
    end
 
    it 'should select_blog one and match it' do 
      blog = Blog.select_one(1)
      blog.title.should == contents_data["blog1"]["title"]
      blog.body.should == contents_data["blog1"]["body"]
    end

    it 'should insert new blog' do 
      @blog.title = 'title_last'
      @blog.body = 'body_last'
      @blog.should be_save_valid
      last_blog = Blog.contents_paginate(1)[:data].first
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
      Blog.count_contents.should == contents_data.count      
    end

    it 'should get content match page' do
      blogs = Blog.contents_paginate(1)[:data] 
      blogs.each_with_index do |blog, i|
        blog.title.should == contents_data["blog#{i+1}"]["title"]
        blog.body.should == contents_data["blog#{i+1}"]["body"]
      end
    end

    it 'should check the page has next content or not' do
      Blog.has_previous?(1).should be_true
      Blog.has_previous?(contents_data.count/ResourceProperty.blog_contents_unit + 1).should be_false
    end
  end
end

