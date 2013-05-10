class BlogsController < Sinatra::Base
  enable :method_override

  get '/blogs' do
    @blogs = Blog.select_all_contents
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
    p params
    Blog.delete_one(params[:id])
    redirect '/blogs'
  end

  delete '/blogs/:blog_id/comments/:id' do
    Comment.delete_one(params[:id])
    redirect "/blogs/#{params[:blog_id]}"
  end


  helpers do
    def message_info(obj)
      return "" if obj.nil?
      obj.created_new? ? "new" : ""
    end

    def show_error_message(obj)
      return "" if obj.nil?
      (obj.error_message || []).join("<br />")
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
