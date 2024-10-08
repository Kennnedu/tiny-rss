require_relative '../spec_helper'

describe 'Post' do
  before do
    Feeds.insert(url: 'https://habr.com/ru/rss/all/all/?fl=ru')
  end

  let(:feed) { Feeds.all.last }

  describe 'starred post' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: "https://example.com",
        title: "example",
        image: 'https://example.com/image.png',
        description: 'Lorem ipsum text',
        published_at: '2022-08-23t10:49:56.000z',
        starred_at: '2022-08-23t10:49:56.000z'
      )
    end

    let(:post) { Posts.all.last }

    it 'displays all posts info' do
      visit "/posts/#{post[:id]}"
      assert_text 'example'
      assert_text 'Lorem ipsum text'
      assert has_css?('img[src="https://example.com/image.png"]')
      assert_link '🔗 Open Article'
      assert_link '✏️ Edit'
      assert has_button? '⭐ Remove Star'
      assert has_button? '📑 Read Later'
      assert has_button? '📋 Copy to Clipboard'
    end

    describe 'remove star' do
      before do
        visit "/posts/#{post[:id]}"
        click_button '⭐ Remove Star'
      end

      it 'displays star button' do
        assert has_button? '⭐ Star'
      end
    end
  end

  describe 'read_later post' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: "https://example.com",
        title: "example",
        image: 'https://example.com/image.png',
        description: 'Lorem ipsum text',
        published_at: '2022-08-23t10:49:56.000z',
        read_later_at: '2022-08-23t10:49:56.000z'
      )
    end

    let(:post) { Posts.all.last }

    it 'displays all posts info' do
      visit "/posts/#{post[:id]}"
      assert_text 'example'
      assert_text 'Lorem ipsum text'
      assert has_css?('img[src="https://example.com/image.png"]')
      assert_link '🔗 Open Article'
      assert_link '✏️ Edit'
      assert has_button? '⭐ Star'
      assert has_button? '📑 Remove Read Later'
      assert has_button? '📋 Copy to Clipboard'
    end

    describe 'remove read later' do
      before do
        visit "/posts/#{post[:id]}"
        click_button '📑 Remove Read Later'
      end

      it 'displays read later button' do
        assert has_button? '📑 Read Later'
      end
    end
  end

  describe 'viewed post' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: "https://example.com",
        title: "example",
        image: 'https://example.com/image.png',
        description: 'Lorem ipsum text',
        published_at: '2022-08-23t10:49:56.000z',
        viewed_at: '2022-08-23t10:49:56.000z'
      )
    end

    let(:post) { Posts.all.last }

    it 'displays all posts info' do
      visit "/posts/#{post[:id]}"
      assert_text 'example'
      assert_text 'Lorem ipsum text'
      assert has_css?('img[src="https://example.com/image.png"]')
      assert_link '🔗 Open Article'
      assert_link '✏️ Edit'
      assert has_button? '⭐ Star'
      assert has_button? '📑 Read Later'
      assert has_button? '📋 Copy to Clipboard'
    end

    describe 'read later' do
      before  do
        visit "/posts/#{post[:id]}"
        click_button '📑 Read Later'
      end

      it 'displays remove read later' do
        assert has_button? '📑 Remove Read Later'
      end
    end

    describe 'star' do
      before  do
        visit "/posts/#{post[:id]}"
        click_button '⭐ Star'
      end

      it 'displays remove read later' do
        assert has_button? '⭐ Remove Star'
      end
    end

    describe 'copy to clipboard' do
      before do
        visit "/posts/#{post[:id]}"
        click_button '📋 Copy to Clipboard'
      end

      it 'coppied to clipboard' do
        skip 'have to add compatible driver with executing js'
      end
    end
  end
end
