require 'sequel'
require 'logger'
require 'nokogiri'
require 'rss'
require 'sinatra'
require 'dry-struct'
require 'dry-types'

DB = Sequel.connect(ENV['DATABASE_URL'])
DB.logger = Logger.new(STDOUT)
Posts = DB[:posts].extension(:pagination)
Feeds = DB[:feeds]

module Types
  include Dry.Types()
end

class PostsParams < Dry::Struct
  transform_keys(&:to_sym)

  attribute :unviewed, Types::Params::Bool.default(false.freeze)
  attribute :starred, Types::Params::Bool.default(false.freeze)
  attribute :published_lt, Types::Params::Integer.default { Time.now.to_i }
  attribute :published_gt, Types::Params::Integer.optional.default { nil }
  attribute :feed_id, Types::Params::Integer.optional.default { nil }
  attribute :page, Types::Params::Integer.default(1.freeze)
end

class PostsQuery
  PER_PAGE = 8.freeze

  def self.call(scope = Posts, params)
    if params[:unviewed]
      scope = scope.where(viewed_at: nil)
    end

    if params[:starred]
      scope = scope.exclude(starred_at: nil)
    end

    if params[:published_lt]
      scope = scope.where(Sequel.lit('published_at < ?', Time.at(params[:published_lt])))
    end

    if params[:published_gt]
      scope = scope.where(Sequel.lit('published_at > ?', Time.at(params[:published_gt])))
    end

    if params[:feed_id]
      scope = scope.where(feed_id: params[:feed_id])
    end

    scope = scope.order(:published_at).reverse
    scope
  end

  def self.paginate(scope = Posts, page)
    scope = scope.paginate(page, PER_PAGE)
    scope
  end
end

get '/' do
  @starred_count = Posts.exclude(starred_at: nil).count
  @unviewed_count = Posts.where(viewed_at: nil).count
  @unreaded_feeds_today_params = { published_gt: Date.today.to_time.to_i, published_lt: (Date.today + 1).to_time.to_i, unviewed: true }
  @unreaded_feeds_today_count = PostsQuery.call(@unreaded_feeds_today_params).count
  @feeds = Feeds.select(:id, :url).to_a
  @unreaded_feeds_counts = Posts.where(viewed_at: nil).group_and_count(:feed_id).as_hash(:feed_id, :count)
  erb :index
end

get '/posts' do
  @posts_params = PostsParams.(params).to_h
  scope = PostsQuery.call(@posts_params)
  @posts = PostsQuery.paginate(scope, @posts_params[:page])
  erb :posts, layout: :layout
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
  posts_params = PostsParams.(params).to_h
  @posts = PostsQuery.call(posts_params)
  @posts.update(viewed_at: Time.at(params[:post][:viewed_at].to_i))
  redirect '/'
end

