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

    def check_previous_page(contents)
      table_name =  contents.first.class.name.downcase+"s"
      first_content =  ConnectDb.get_client.query("SELECT * FROM #{table_name} where id=(select min(id) from #{table_name})").first
      if contents.first.id != first_content["id"]
        "previous"
      else
         ""
      end
    end
    
    def check_next_page(contents)
      table_name =  contents.last.class.name.downcase+"s"
      last_content =  ConnectDb.get_client.query("SELECT * FROM #{table_name} where id=(select max(id) from #{table_name})").first
      @next_page = 1
      if contents.last.id != last_content["id"]
        "next"
      else
         ""
      end
    end

    def previous_page(current_page)
      current_page.to_i - ONE_PAGE
    end
  
    def next_page(current_page)
      page = current_page.to_i + ONE_PAGE
      page == ONE_PAGE ? page + ONE_PAGE : page
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
