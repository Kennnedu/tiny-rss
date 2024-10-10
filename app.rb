require 'sinatra'

require_relative './post'
require_relative './db'

set :erb, trim: '-'

get '/' do
  @starred_count = Posts.exclude(starred_at: nil).count
  @read_later_count = Posts.exclude(read_later_at: nil).count
  @unviewed_count = Posts.where(viewed_at: nil).count
  @unreaded_feeds_today_params = {
    published_gt: Date.today.to_time.to_i,
    published_lt: (Date.today + 1).to_time.to_i,
    unviewed: true
  }
  @unreaded_feeds_today_count = PostsQuery.call(@unreaded_feeds_today_params).count
  @feeds = Feeds.select(:id, :url).to_a
  @unreaded_feeds_counts = Posts.where(viewed_at: nil).group_and_count(:feed_id).as_hash(:feed_id, :count)
  erb :index
end

get '/posts' do
  @posts_params = PostsParams.call(params)
  scope = PostsQuery.call(@posts_params)
  @posts = PostsQuery.paginate(scope, @posts_params[:page])
  @posts_rest = @posts.pagination_record_count -
                ((@posts_params[:page] - 1) * PostsQuery::PER_PAGE + @posts.current_page_record_count)
  template = "posts/#{@posts_params.template}"

  erb template.to_sym
end

post '/posts' do
  feed = Feeds.where(url: DEFAULT_FEED).first
  
  Posts.insert(
    feed_id: feed[:id],
    title: params['title'],
    link: params['link'],
    image: params['image'],
    description: params['description'],
    published_at: Time.now,
    starred_at: Time.now
  )

  redirect '/'
end

get '/posts/new' do
  erb :'posts/new'
end

post '/posts/check' do
  result = Post.new.fetch(params['link'])
  result.is_a?(Post) ? @post = result : @error = result
  erb :'posts/new'
end

get '/posts/:id' do
  post = Posts.where(id: params['id'])
  @post = post.first
  post.update(viewed_at: Time.now) unless @post[:viewed_at]
  erb :'posts/show'
end

get '/posts/:id/edit' do
  post = Posts.where(id: params['id'])
  @post = post.first
  erb :'posts/edit'
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

  redirect "/posts/#{params[:id]}"
end

patch '/posts/:id/read_later' do
  post = Posts.where(id: params[:id])
  read_later_at = post.first[:read_later_at] ? nil : Time.now
  post.update(read_later_at: read_later_at)

  redirect "/posts/#{params[:id]}"
end

put '/posts/view' do
  posts_params = PostsParams.call(params).to_h
  @posts = PostsQuery.call(posts_params)
  @posts.update(viewed_at: Time.at(params[:viewed_at].to_i))
  redirect '/'
end

put '/posts/:id' do
  post = Posts.where(id: params['id'])
  post.update(
    title: params['title'],
    image: params['image'],
    description: params['description'],
  )
  redirect "/posts/#{params['id']}"
end

