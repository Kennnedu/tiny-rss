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
  attribute :template, Types::String.default('titles'.freeze).enum('magazine', 'titles', 'compact', 'component')
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

    if params[:template] == 'titles'
      scope = scope.select(:id, :title, :link, :published_at, :viewed_at, :starred_at)
    elsif params[:template] == 'compact'
      scope = scope.select(:id, :title, :link, :description, :published_at, :viewed_at, :starred_at)
    end

    scope = scope.order(:published_at).reverse
    scope
  end

  def self.paginate(scope = Posts, page)
    scope = scope.paginate(page, PER_PAGE)
    scope
  end
end

set :erb, :trim => '-'

get '/' do
  ScoutApm::Rack.transaction("get /", request.env) do
    @starred_count = Posts.exclude(starred_at: nil).count
    @unviewed_count = Posts.where(viewed_at: nil).count
    @unreaded_feeds_today_params = { published_gt: Date.today.to_time.to_i, published_lt: (Date.today + 1).to_time.to_i, unviewed: true }
    @unreaded_feeds_today_count = PostsQuery.call(@unreaded_feeds_today_params).count
    @feeds = Feeds.select(:id, :url).to_a
    @unreaded_feeds_counts = Posts.where(viewed_at: nil).group_and_count(:feed_id).as_hash(:feed_id, :count)
    erb :index
  end
end

get '/posts' do
  ScoutApm::Rack.transaction("get /posts", request.env) do
    @posts_params = PostsParams.(params)
    scope = PostsQuery.call(@posts_params)
    @posts = PostsQuery.paginate(scope, @posts_params[:page])
    erb :"posts/#{@posts_params.template}"
  end
end

get '/posts/:id/redirect' do
  ScoutApm::Rack.transaction("get /posts/:id/redirect", request.env) do
    post = Posts.where(id: params['id'])
    post.update(viewed_at: Time.now)
    redirect post.first[:link]
  end
end

patch '/posts/:id/star' do
  ScoutApm::Rack.transaction("patch /posts/:id/star", request.env) do
    post = Posts.where(id: params[:id])
    starred_at = post.first[:starred_at] ? nil : Time.now
    post.update(starred_at: starred_at)
    redirect "/posts"
  end
end

put '/posts/view' do
  ScoutApm::Rack.transaction("put /posts/view", request.env) do
    posts_params = PostsParams.(params).to_h
    @posts = PostsQuery.call(posts_params)
    @posts.update(viewed_at: Time.at(params[:post][:viewed_at].to_i))
    redirect '/'
  end
end

