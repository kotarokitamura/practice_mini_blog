class BlogsController < Sinatra::Base
  enable :method_override
  get '/blogs' do
    @blogs = Blog.select_all_blogs
    haml :index
  end

  get '/blogs/:id' do
    set_blog
    set_comments
    haml :show
  end

  get '/blogs/new/' do
    @blog = Blog.new
    haml :new
  end

  get '/blogs/:id/edit' do
    set_blog
    haml :edit
  end

  put '/blogs/:id' do
    set_blog
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

  post '/blogs/:id/comments' do
    @comment = Comment.new
    @comment.set_params(params)
    if @comment.save_valid?
      redirect '/blogs'
    else 
      set_blog
      set_comments
      haml :show
    end
  end

  delete '/blogs/:id' do
    p params
    Blog.delete_one(params)
    redirect '/blogs'
  end

  delete '/blogs/:id/comments/:id' do
    Comment.delete_one(params)
    redirect '/blogs'
  end


  helpers do
    def blog_message(blog)
      blog.created_new? ? "new" : ""
    end
     
    def comment_message(comment)
      comment.created_new? ? "new" : ""
    end
  end


  private
  def set_blog
    @blog = Blog.select_blog(params)
  end

  def set_comments
    @comments = Comment.select_all_comments(params)
  end
end
