class BlogsController < Sinatra::Base
  enable :method_override

  get '/blogs' do
    @blogs = Blog.contents_paginate(params[:page])
    haml :index
  end

  get '/blogs/:id/image' do
    @images = Image.get_images(params[:id])
    haml :image
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

  post '/blogs/:id/image' do
    @image = Image.new 
    @images = Image.get_images(params[:id])
    if @image.upload_file?(params)
      redirect "/blogs/#{params[:id]}/image"
    else
      haml :image
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

  delete '/blogs/:id/image' do
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

    def next_message(content)  
      content[:page_info][:has_next] ? "next" : "" 
    end

    def previous_message(content)
      content[:page_info][:has_previous] ? "previous" : "" 
    end

    def next_page(content)
      content[:page_info][:current_page] - 1
    end

    def previous_page(content)
      content[:page_info][:current_page] + 1
    end
    
    def delete_button(obj)
      !obj.empty?
    end
  end

  private
  def set_blog(id_str)
    @blog = Blog.select_one(id_str)
  end

  def set_comments
    @comments = Comment.contents_paginate(nil,@blog)[:data]
  end
end
