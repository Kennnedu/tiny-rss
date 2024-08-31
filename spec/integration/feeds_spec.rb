require_relative '../spec_helper'

describe 'Feeds' do
  before do
    feeds = JSON.parse(File.read('/app/spec/test_files/feeds.json'))
    posts = JSON.parse(File.read('/app/spec/test_files/posts.json'))
    feeds.each { |feed| Feeds.insert(feed) }
    posts.each { |post| Posts.insert(post) }
    Posts.insert(feed_id: 2, link: "https:\/\/habr.com\/ru\/post\/695800\/?utm_source=habrahabr&utm_medium=rss&utm_campaign=695800", published_at: Time.now)
  end

  it 'index' do
    visit '/'
    assert_link 'Today'
    assert_text 'Today 1'
    assert_link 'Starred'
    assert_text 'Starred 2'
    assert_link 'Read Later'
    assert_text 'Read Later 1'
    assert_link 'people.onliner.by'
    assert_text 'people.onliner.by 1'
    assert_link 'habr.com'
    assert_text 'habr.com 1'
  end
end
