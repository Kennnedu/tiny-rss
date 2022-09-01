require 'sequel'
require 'logger'
require 'nokogiri'
require 'rss'
require 'sinatra'

DB = Sequel.connect(ENV['DATABASE_URL'])
DB.logger = Logger.new(STDOUT)
Posts = DB[:posts].extension(:pagination)
Feeds = DB[:feeds]

POSTS_PER_PAGE = 8.freeze

get '/posts' do
  @loaded_at = params[:loaded_at] ? Time.at(params[:loaded_at].to_i) : Time.now
  page = params[:page] ? params[:page].to_i : 1
  @posts = Posts.where(viewed_at: nil).where(Sequel.lit('published_at < ?', @loaded_at))
    .order(:published_at).reverse.paginate(page, POSTS_PER_PAGE)
  erb :posts, layout: :layout
end

get '/posts_starred' do
  page = params[:page] ? params[:page].to_i : 1
  @posts = Posts.exclude(starred_at: nil).order(:published_at).reverse
    .paginate(page, POSTS_PER_PAGE)
  erb :posts_starred, layout: :layout
end

get '/posts/:id/redirect' do
  post = Posts.where(id: params['id'])
  post.update(viewed_at: Time.now)
  redirect post.first[:link]
end

patch '/posts/:id/star' do
  post = Posts.where(id: params[:id])
  starred_at = post.first[:starred_at] ? nil : Time.now
  post.update(starred_at: starred_at)
  redirect "/posts"
end

put '/posts/view' do
  Posts.where(viewed_at: nil).where(Sequel.lit('published_at < ?', params[:viewed_at])).update(viewed_at: params[:viewed_at])
  redirect '/posts'
end

