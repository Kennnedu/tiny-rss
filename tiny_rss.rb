require 'roda'

require_relative './post'
require_relative './db'

class TinyRss < Roda
  plugin :render
  plugin :public, root: 'public'

  route do |r|
    r.public
    r.root do
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
      render 'index'
    end

    r.on 'posts' do
      r.get 'new' do
        render 'posts/new', locals: { params: r.params }
      end

      r.post 'check' do
        result = Post.new.fetch(r.params['link'])
        result.is_a?(Post) ? @post = result : @error = result
        render 'posts/new', locals: { params: r.params }
      end

      r.post 'view' do
        posts_params = PostsParams.call(r.params).to_h
        @posts = PostsQuery.call(posts_params)
        @posts.update(viewed_at: Time.at(r.params[:viewed_at].to_i))
        r.redirect '/'
      end

      r.on Integer do |post_id|
        post = Posts.where(id: post_id)
        @post = post.all[0]

        r.post 'star' do
          starred_at = @post[:starred_at] ? nil : Time.now
          post.update(starred_at: starred_at)

          r.redirect "/posts/#{post_id}"
        end

        r.post 'read_later' do
          read_later_at = @post[:read_later_at] ? nil : Time.now
          post.update(read_later_at: read_later_at)

          r.redirect "/posts/#{post_id}"
        end

        r.post do
          post.update(
            title: r.params['title'],
            image: r.params['image'],
            description: r.params['description'],
          )

          r.redirect "/posts/#{post_id}"
        end

        r.get 'redirect' do
          post.update(viewed_at: Time.now)

          r.redirect @post[:link]
        end

        r.get 'edit' do
          render 'posts/edit'
        end

        r.get do
          post.update(viewed_at: Time.now) unless @post[:viewed_at]
          render 'posts/show'
        end
      end

      r.post do
        feed = Feeds.where(url: DEFAULT_FEED).first

        Posts.insert(
          feed_id: feed[:id],
          title: r.params['title'],
          link: r.params['link'],
          image: r.params['image'],
          description: r.params['description'],
          published_at: Time.now,
          starred_at: Time.now
        )

        r.redirect '/'
      end

      r.get do
        @posts_params = PostsParams.call(r.params)
        scope = PostsQuery.call(@posts_params)
        @posts = PostsQuery.paginate(scope, @posts_params[:page])
        @posts_rest = @posts.pagination_record_count -
                      ((@posts_params[:page] - 1) * PostsQuery::PER_PAGE + @posts.current_page_record_count)
        template = "posts/#{@posts_params.template}"

        render template.to_sym, locals: { params: r.params }
      end
    end
  end
end
