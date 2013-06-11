# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/spec_helper.rb") 

describe Comment do
 include SettingDb 
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
    before(:all) do
      fixture :comment
    end
    
    it 'should get all comments same blog_id' do 
      Comment.contents_paginate(nil,@blog)[:data].each do |comment| 
        comment.blog_id.should  == 1 
      end 
    end

    it 'should delete comment' do 
      Comment.delete_one(1)
      Comment.contents_paginate(nil,@blog)[:data].each do |comment|
        comment.id.should_not == 1 
      end
    end
  end 
 
  context 'with using paginate module' do 
    before do
      fixture :comment
    end
   
    it 'should get contents only limited number' do
      Comment.contents_paginate(nil,@blog)[:data].count.should == Comment::COMMENT_CONTENTS_UNIT
      Comment.contents_paginate(nil,@blog)[:data].last.body.should_not == @contents_data.last[:body]
    end

    after do 
      drop_table
    end
  end
end
