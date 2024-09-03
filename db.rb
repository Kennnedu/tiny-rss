require 'sequel'
require 'dry-struct'
require 'dry-types'
require 'logger'

DB = if ENV['APP_ENV'] == 'test'
      Sequel.sqlite(database: './tiny_rss_test.sqlite3'.freeze)
     else
      Sequel.sqlite(database: './tiny_rss.sqlite3'.freeze)
     end

if ENV['APP_ENV'] != 'test'
  DB.logger = Logger.new($stdout)
end

Posts = DB[:posts].extension(:pagination)
Feeds = DB[:feeds]

module Types
  include Dry.Types()
end

class PostsParams < Dry::Struct
  transform_keys(&:to_sym)

  attribute :unviewed, Types::Params::Bool.default(false)
  attribute :starred, Types::Params::Bool.default(false)
  attribute :read_later, Types::Params::Bool.default(false)
  attribute :published_lt, Types::Params::Integer.default { Time.now.to_i }
  attribute :published_gt, Types::Params::Integer.optional.default(nil)
  attribute :feed_id, Types::Params::Integer.optional.default(nil)
  attribute :page, Types::Params::Integer.default(1)
  attribute :template, Types::String.default('titles'.freeze).enum('magazine', 'titles', 'compact', 'component')
  attribute :stream, Types::Params::Bool.default(false)
end

class PostsQuery
  PER_PAGE = 8

  def self.call(scope = Posts, params)
    scope = scope.where(viewed_at: nil) if params[:unviewed]

    scope = scope.exclude(starred_at: nil) if params[:starred]

    scope = scope.exclude(read_later_at: nil) if params[:read_later]

    scope = scope.where(Sequel.lit('published_at < ?', Time.at(params[:published_lt]))) if params[:published_lt].is_a?(Integer)

    scope = scope.where(Sequel.lit('published_at > ?', Time.at(params[:published_gt]))) if params[:published_gt].is_a?(Integer)

    scope = scope.where(feed_id: params[:feed_id]) if params[:feed_id]

    if params[:template] == 'titles'
      scope = scope.select(:id, :title, :link, :published_at, :viewed_at, :starred_at)
    elsif params[:template] == 'compact'
      scope = scope.select(:id, :title, :link, :description, :published_at, :viewed_at, :starred_at)
    end

    scope.order(:published_at).reverse
  end

  def self.paginate(scope = Posts, page)
    scope.paginate(page, PER_PAGE)
  end
end


