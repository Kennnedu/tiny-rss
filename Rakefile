require_relative './app'
require 'feedjira'
require 'httparty'

desc 'Setup DB schema'
task :db_setup do
  DB.create_table(:feeds) do
    primary_key :id
    String :url, null: false
  end
  DB.create_table(:posts) do
    primary_key :id
    foreign_key :feed_id, :feeds, null: false
    String :link, null: false#, unique: true
    String :title
    String :image
    String :description, text: true
    Time :published_at
    Time :viewed_at
    Time :starred_at
  end
end

desc 'Fetch feeds'
task :fetch_feeds do
  Feeds.all.each do |feed|
    last_publish = Posts.where(feed_id: feed[:id]).order(:published_at).reverse.first&.[](:published_at) || Time.now.utc - (60 * 60 * 24 * 100)

    feed_raw = HTTParty.get(feed[:url]).body
    Feedjira.parse(feed_raw).entries.each do |item|
      item_time = Time.at(item.published.to_i)
      next if item_time <= last_publish

      Posts.insert({
        feed_id: feed[:id],
        image: item.image,
        title: item.title,
        description: Nokogiri::HTML(item.summary).text.strip[0..399],
        link: item.url,
        published_at: item_time,
      })
    end
  end
end
