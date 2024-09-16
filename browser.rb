require 'ferrum'

class Browser
  WS_URL = 'ws://127.0.0.1:9222'
  TIMEOUT = 20

  def initialize
    @browser = Ferrum::Browser.new(ws_url: WS_URL, timeout: TIMEOUT)
  end

  def screen_base64(page_url)
    page = @browser.create_page
    page.go_to(page_url)
    image = page.screenshot(full: true, quality: 60, encoding: :base64)
    @browser.reset
    image
  end

  attr_reader :browser
end

