require_relative '../spec_helper'

describe 'Posts' do
  before do
    Feeds.insert(url: 'https://habr.com/ru/rss/all/all/?fl=ru')
  end

  let(:feed) { Feeds.all.last }

  describe 'posts list page' do
    it 'displays links' do
      visit '/posts'
      assert_link '+ Add new post'
    end

    describe 'starred param' do
      describe '1 not starred post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z',
          )
        end

        describe 'starred is true' do
          it 'doesn\'t display any posts' do
            visit '/posts?starred=true'
            assert_text 'There are no articles.'
          end
        end

        describe 'starred is false' do
          it 'display all posts' do
            visit '/posts?starred=false'
            assert_link 'example'
          end
        end
      end

      describe '1 starred post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z',
            starred_at: '2022-08-23t10:50:56.000z'
          )
        end

        describe 'starred is true' do
          it 'displays only starred post' do
            visit '/posts?starred=true'
            assert_link 'example'
          end
        end

        describe 'starred is false' do
          it 'displays all posts' do
            visit '/posts?starred=false'
            assert_link 'example'
          end
        end
      end
    end

    describe 'unviewed param' do
      describe '1 viewed post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z',
            viewed_at: '2022-08-23t10:50:56.000z'
          )
        end

        describe 'unviewed is true' do
          it 'doesn\'t display any posts' do
            visit '/posts?unviewed=true'
            assert_text 'There are no articles.'
          end
        end

        describe 'unviewed is false' do
          it 'displays all posts' do
            visit '/posts?unviewed=false'
            assert_link 'example'
          end
        end
      end

      describe '1 unviewed post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z'
          )
        end

        describe 'unviewed is true' do
          it 'displays only unviewed post' do
            visit '/posts?unviewed=true'
            assert_link 'example'
          end
        end

        describe 'unviewed is false' do
          it 'displays all posts' do
            visit '/posts?unviewed=false'
            assert_link 'example'
          end
        end
      end
    end

    describe 'read_later param' do
      describe '1 read_later post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z',
            read_later_at: '2022-08-23t10:50:56.000z'
          )
        end

        describe 'read_later is true'  do
          it 'displays real_later post' do
            visit '/posts?read_later=true'
            assert_link 'example'
          end
        end

        describe 'read_later is false'  do
          it 'displays all posts' do
            visit '/posts?read_later=false'
            assert_link 'example'
          end
        end
      end

      describe '1 not read_later post' do
        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: '2022-08-23t10:49:56.000z'
          )
        end

        describe 'read_later is true'  do
          it 'doesn\'t display any posts' do
            visit '/posts?read_later=true'
            assert_text 'There are no articles.'
          end
        end

        describe 'read_later is false'  do
          it 'display all posts' do
            visit '/posts?read_later=false'
            assert_link 'example'
          end
        end
      end
    end

    describe 'page param' do
      it 'doesn\'t display new post link' do
        visit '/posts?page=2'
        assert_no_link '+ Add new post'
      end

      describe '8 posts per page' do
        before do
          8.times do |i|
            Posts.insert(
              feed_id: feed[:id],
              link: "https://example.com/#{i}",
              title: "example #{i}",
              published_at: '2022-08-23t10:49:56.000z',
            )
          end
        end

        it 'doesn\'t display any posts on second page'  do
          visit '/posts?page=2'
          assert_no_selector('#posts>article')
        end
      end

      describe '10 posts' do
        before do
          1.upto(10) do |i|
            Posts.insert(
              feed_id: feed[:id],
              link: "https://example.com/#{i}",
              title: "example #{i}",
              published_at: '2022-08-23t10:49:56.000z',
            )
          end
        end

        it 'displays 2 posts on second page' do
          visit '/posts?page=2'
          assert_link('example 9')
          assert_link('example 10')
        end
      end
    end

    describe 'feed_id param' do
      before do
        Posts.insert(
          feed_id: feed[:id],
          link: "https://example.com",
          title: "example",
          published_at: '2022-08-23t10:49:56.000z'
        )
      end

      describe 'feed_id param eql belonging feed' do
        it 'displays post' do
          visit "/posts?feed_id=#{feed[:id]}"
          assert_link 'example'
        end
      end

      describe 'feed_id param not eql belonging feed' do
        it 'displays post' do
          visit "/posts?feed_id=#{feed[:id] + 1}"
          assert_text 'There are no articles.'
        end
      end
    end

    describe 'published_lt param' do
      let(:published_lt) { 1661251796 }

      describe 'post published_at less than published_lt' do
        let(:published_at) { Time.at(published_lt - 2 * 60) } # minus two minutes

        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: published_at
          )
        end

        it 'doesn\'t display the post' do
          visit "/posts?published_lt=#{published_lt}"
          assert_link 'example'
        end
      end

      describe 'post published_at more than published_lt' do
        let(:published_at) { Time.at(published_lt + 2 * 60) } # plus two minutes

        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: published_at
          )
        end

        it 'doesn\'t display the post' do
          visit "/posts?published_lt=#{published_lt}"
          assert_text 'There are no articles.'
        end
      end
    end

    describe 'published_gt param' do
      let(:published_gt) { 1661251796 }

      describe 'post published_at less than published_gt' do
        let(:published_at) { Time.at(published_gt - 2 * 60) } # minus two minutes

        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: published_at
          )
        end

        it 'doesn\'t display the post' do
          visit "/posts?published_gt=#{published_gt}"
          assert_text 'There are no articles.'
        end
      end

      describe 'post published_at more than published_gt' do
        let(:published_at) { Time.at(published_gt + 2 * 60) } # plus two minutes

        before do
          Posts.insert(
            feed_id: feed[:id],
            link: "https://example.com",
            title: "example",
            published_at: published_at
          )
        end

        it 'doesn\'t display the post' do
          visit "/posts?published_gt=#{published_gt}"
          assert_link 'example'
        end
      end
    end

    describe 'template param' do
      before do
        Posts.insert(
          feed_id: feed[:id],
          link: "https://example.com",
          title: "example",
          image: 'https://example.com/image.png',
          description: 'Lorem ipsum text',
          published_at: '2022-08-23t10:49:56.000z'
        )
      end

      describe 'without param' do
        it '' do
          visit '/posts'
          assert_link 'example'
          assert_text 'example.com'
          assert_text '23 Aug 2022 10:49 UTC'
        end
      end

      describe 'titles' do
        it 'displays titles template' do
          visit '/posts?template=titles'
          assert_link 'example'
          assert_text 'example.com'
          assert_no_text 'Lorem ipsum text'
          assert_text '23 Aug 2022 10:49 UTC'
          assert has_no_css?('img[src="https://example.com/image.png"]')
        end
      end

      describe 'compact' do
        it 'displays compact template' do
          visit '/posts?template=compact'
          assert_text 'example.com'
          assert_text 'Lorem ipsum text'
          assert_text '23 Aug 2022 10:49 UTC'
          assert has_no_css?('img[src="https://example.com/image.png"]')
        end
      end

      describe 'magazine' do
        it 'displays compact magazine' do
          visit '/posts?template=magazine'
          assert_text 'example.com'
          assert_text 'Lorem ipsum text'
          assert_text '23 Aug 2022 10:49 UTC'
          assert has_css?('img[src="https://example.com/image.png"]')
        end
      end
    end
  end
end
