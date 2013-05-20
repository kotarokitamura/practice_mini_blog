class BlogsController < Sinatra::Base
  enable :method_override

  get '/blogs' do
    @blogs = Blog.contents_paginate(params[:page])
    haml :index
  end

  get '/blogs/:id' do
    set_blog(params[:id])
    set_comments
    haml :show
  end

  get '/blogs/new/' do
    @blog = Blog.new
    haml :new
  end

  get '/blogs/:id/edit' do
    set_blog(params[:id])
    haml :edit
  end

  put '/blogs/:id' do
    set_blog(params[:id])
    @blog.set_params(params)
    if @blog.save_valid?
      redirect '/blogs'
    else
      haml :edit
    end
  end

  post '/blogs' do
    @blog = Blog.new
    @blog.set_params(params)
    if @blog.save_valid?
      redirect '/blogs'
    else
      haml :new
    end
  end

  post '/blogs/:blog_id/comments' do
    @comment = Comment.new
    @comment.set_params(params)
    if @comment.save_valid?
      redirect "/blogs/#{params[:blog_id]}"
    else
      set_blog(params[:blog_id])
      set_comments
      haml :show
    end
  end

  delete '/blogs/:id' do
    Blog.delete_one(params[:id])
    redirect '/blogs'
  end

  delete '/blogs/:blog_id/comments/:id' do
    Comment.delete_one(params[:id])
    redirect "/blogs/#{params[:blog_id]}"
  end


  helpers do
    ONE_PAGE = 1
    def message_info(obj)
      return "" if obj.nil?
      obj.created_new? ? "new" : ""
    end

    def show_error_message(obj)
      return "" if obj.nil?
      (obj.error_message || []).join("<br />")
    end

    def next_page_id(page_num)
      page_num.to_i - ONE_PAGE
    end 

    def next_message(page_num)    
      page_num = ONE_PAGE if  page_num.nil?
      page_num.to_i != ONE_PAGE ? "next" : ""
    end

    def previous_page_id(page_num)
      page_num = ONE_PAGE if  page_num.nil?
      page_num.to_i + ONE_PAGE
    end

    def previous_message(page_num)
      page_num = ONE_PAGE if page_num.nil?
      Blog.has_previous?(page_num) ? "previous" : "" 
    end
  end

  private
  def set_blog(id_str)
    @blog = Blog.select_one(id_str)
  end

  def set_comments
    @comments = Comment.contents_limited(@blog)
  end
end
