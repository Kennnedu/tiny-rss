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
  end
end
