require_relative '../spec_helper'

describe 'Edit Post' do
  before do
    Feeds.insert(url: DEFAULT_FEED)
    feed = Feeds.all[0]
    Posts.insert(
      feed_id: feed[:id],
      link: 'http://localhost:3333/example.html',
      title: 'example',
      image: 'https://example.com/image.png',
      description: 'Lorem ipsum text',
      published_at: '2022-08-23t10:49:56.000z'
    )
    post = Posts.all[0]
    visit "/posts/#{post[:id]}/edit"
  end

  let(:post) { Posts.all[0] }
  
  let(:post_title) { 'Example' }
  let(:image) { 'https://image.com' }
  let(:description) { 'Example description' }

  it 'displays edit post form' do
    assert_field 'link', with: 'http://localhost:3333/example.html', disabled: true
    assert_field 'title', with: 'example'
    assert_field 'image', with: 'https://example.com/image.png'
    assert_field 'description', with: 'Lorem ipsum text'
    assert_button 'Submit'
  end

  describe 'submitting form' do
    before do
      fill_in 'title', with: post_title
      fill_in 'image', with: image
      fill_in 'description', with: description
      click_button 'Submit'
    end

    it 'save the form in db' do
      post = Posts.all[0]
      assert post[:title] == post_title
      assert post[:image] == image
      assert post[:description] == description
    end

    it 'redirects to updated post page' do
      assert_current_path "/posts/#{post[:id]}"
      assert_text post_title
      assert_text description
      assert has_css?("img[src=\"#{image}\"]")
    end
  end

  describe 'submitting empty form' do
    before do
      fill_in 'title', with: ''
      fill_in 'image', with: ''
      fill_in 'description', with: ''
      click_button 'Submit'
    end

    it 'save the form in db' do
      post = Posts.all[0]
      assert post[:title] == ''
      assert post[:image] == ''
      assert post[:description] == ''
    end

    it 'redirects to updated post page' do
      assert_current_path "/posts/#{post[:id]}"
      assert_no_text post_title
      assert_no_text description
      assert has_no_css?("img[src=\"#{image}\"]")
    end
  end
end
