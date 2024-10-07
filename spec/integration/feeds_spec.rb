require_relative '../spec_helper'

describe 'Feeds' do
  before do
    Feeds.insert(url: 'https://habr.com/ru/rss/all/all/?fl=ru')
  end

  let(:feed) { Feeds.all[0] }

  it 'displays links' do
    visit '/'
    assert_link 'Today'
    assert_link 'Starred'
    assert_link 'Read Later'
    assert_link 'habr.com'
  end

  describe 'starred post' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: 'https://example.com',
        published_at: '2022-08-23T10:49:56.000Z',
        starred_at: '2022-08-24T05:55:13.428Z',
      )
    end

    it 'increases starred and feed counters' do
      visit '/'
      assert_text 'Starred 1'
      assert_text 'habr.com 1'
    end
    
    it 'doesn\'t increase today and read_later counter' do
      visit '/'
      assert_no_text 'Read Later 1'
      assert_no_text 'Today 1'
    end
  end

  describe 'post marked as read_later' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: 'https://example.com',
        published_at: '2022-08-23T10:49:56.000Z',
        read_later_at: '2022-08-24T05:55:13.428Z',
      )
    end

    it 'increases read_later and feed counters' do
      visit '/'
      assert_text 'Read Later 1'
      assert_text 'habr.com 1'
    end

    it 'doesn\'t increase starred and today counter' do
      visit '/'
      assert_no_text 'Starred 1'
      assert_no_text 'Today 1'
    end
  end

  describe 'post published today' do
    before do
      Posts.insert(
        feed_id: feed[:id],
        link: 'https://example.com',
        published_at: Time.now.to_s,
      )
    end

    it 'increases today and feed counters' do
      visit '/'
      assert_text 'Today 1'
      assert_text 'habr.com 1'
    end

    it 'doesn\'t increase read_later and starred counters' do
      visit '/'
      assert_no_text 'Read Later 1'
      assert_no_text 'Starred 1'
    end
  end
end
