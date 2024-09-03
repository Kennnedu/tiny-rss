require 'sinatra'

require_relative './db'

set :erb, trim: '-'

get '/' do
  @starred_count = Posts.exclude(starred_at: nil).count
  @read_later_count = Posts.exclude(read_later_at: nil).count
  @unviewed_count = Posts.where(viewed_at: nil).count
  @unreaded_feeds_today_params = {
    published_gt: Date.today.to_time.to_i,
    published_lt: (Date.today + 1).to_time.to_i,
    unviewed: true,
    template: :component
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

  if @posts_params[:stream]
    response.headers['Content-Type'] = 'text/vnd.turbo-stream.html; charset=utf-8'
    erb "#{template}_stream".to_sym, layout: false
  else
    erb template.to_sym
  end
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

  if params[:stream]
    response.headers['Content-Type'] = 'text/vnd.turbo-stream.html; charset=utf-8'
    erb :'posts/component/_update', layout: false, locals: { post: post.first.to_h }
  else
    redirect '/posts'
  end
end

patch '/posts/:id/read_later' do
  post = Posts.where(id: params[:id])
  read_later_at = post.first[:read_later_at] ? nil : Time.now
  post.update(read_later_at: read_later_at)

  if params[:stream]
    response.headers['Content-Type'] = 'text/vnd.turbo-stream.html; charset=utf-8'
    erb :'posts/component/_update', layout: false, locals: { post: post.first.to_h }
  else
    redirect '/posts'
  end
end

put '/posts/view' do
  posts_params = PostsParams.call(params).to_h
  @posts = PostsQuery.call(posts_params)
  @posts.update(viewed_at: Time.at(params[:post][:viewed_at].to_i))
  redirect '/'
end
