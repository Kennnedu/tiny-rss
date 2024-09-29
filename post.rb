require 'httparty'
require 'nokogiri'

Post = Struct.new(:title, :link, :description, :image) do
  def fetch(url)
    self.link = url
    response = HTTParty.get(link, headers: { 'User-Agent' => 'Ruby Meta Scraper' })
    head_content = response.body[/\<head.*?\<\/head\>/m]

    if head_content.nil?
      return self
    end

    head = Nokogiri::HTML(head_content)

    self.title = head&.xpath('//title').text.strip
    self.image = head&.at('meta[property="og:image"]')&.[]('content')
    self.description = head&.at('meta[name="description"]')&.[]('content') || head&.at('meta[property="og:description"]')&.[]('content')
    self
  end
end
