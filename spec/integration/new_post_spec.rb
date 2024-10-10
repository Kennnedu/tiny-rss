require_relative '../spec_helper'

describe 'New Post' do
  before do
    Feeds.insert(url: DEFAULT_FEED)
    visit '/posts/new'
  end

  let(:default_feed) { Feeds.all.last }

  it 'displays link form' do
    assert_field 'link'
    assert_button 'Submit'
  end

  describe 'submitting link form' do
    before do
      fill_in 'link', with: 'http://localhost:3333/example.html'
      click_button 'Submit'
    end

    it 'displays new post form' do
      assert_current_path '/posts/check'
      assert_field 'link', with: 'http://localhost:3333/example.html', readonly: true
      assert_field 'title', with: 'Sample Post Title'
      assert_field 'image', with: 'https://www.example.com/images/sample-og-image.jpg'
      assert_field 'description', with: 'This is a sample post page with meta tags, including Open Graph tags for social sharing.'
      assert_button 'Submit'
    end

    describe 'submitting post form' do
      let(:post_title) { 'Example' }
      let(:image) { 'https://image.com' }
      let(:description) { 'Example description' }

      before do
        fill_in 'title', with: post_title
        fill_in 'image', with: image
        fill_in 'description', with: description
        click_button 'Submit'
      end

      it 'creates new post in db' do
        post = Posts.all.last
        assert post[:title] == post_title
        assert post[:image] == image
        assert post[:description] == description
      end

      it 'redirects to feeds page & update counters' do
        assert_current_path '/'
        assert_text 'Today 1'
        assert_text 'Starred 1'
        assert_text 'DEFAULT 1'
        assert_no_text 'Read Later 1'
      end
    end

    describe 'submitting empty form' do
      let(:post_title) { '' }
      let(:image) { '' }
      let(:description) { '' }

      before do
        fill_in 'title', with: post_title
        fill_in 'image', with: image
        fill_in 'description', with: description
        click_button 'Submit'
      end

      it 'creates new post in db' do
        post = Posts.all.last
        assert post[:title] == post_title
        assert post[:image] == image
        assert post[:description] == description
      end

      it 'redirects to feeds page & update counters' do
        assert_current_path '/'
        assert_text 'Today 1'
        assert_text 'Starred 1'
        assert_text 'DEFAULT 1'
        assert_no_text 'Read Later 1'
      end
    end
  end

  describe 'submitting empty link form' do
    before do
      fill_in 'link', with: 'https://localhost123123123'
      click_button 'Submit'
    end

    it 'doesn\'t allow submit form' do
      assert_text 'Unprocessable link'
      assert_no_field 'title'
      assert_no_field 'image'
      assert_no_field 'description'
    end
  end
end
