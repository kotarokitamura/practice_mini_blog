class BlogsController < Sinatra::Base
  enable :method_override

  get '/blogs' do
    @blogs = Blog.content_paginate()
    haml :index
  end

  get '/blogs/:id' do
    set_blog(params[:id])
    set_comments
    haml :show
  end

  get '/blogs/page/:id' do
    @blogs = Blog.content_paginate(params[:id])
    haml :index
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
    p params
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

    def check_previous_page(content)
      !content.class.previous_show_page(content).nil? ? "previous" : ""
    end
    
    def check_next_page(content)
      !content.class.next_show_page(content).nil? ? "next" : ""
    end

    def previous_page(current_page)
      page = current_page.to_i + ONE_PAGE
      page == ONE_PAGE ? page + ONE_PAGE : page
    end
  
    def next_page(current_page)
      current_page.to_i - ONE_PAGE
    end 

    def previous_show_page_id(content)
      content.class.previous_show_page(content).id unless content.class.previous_show_page(content).nil?
    end
  
    def next_show_page_id(content)
      content.class.next_show_page(content).id unless content.class.next_show_page(content).nil?
    end
  end

  private
  def set_blog(id_str)
    @blog = Blog.select_one(id_str)
  end

  def set_comments
    @comments = Comment.select_all_contents(@blog)
  end
end
