require 'selenium-webdriver'
require "rspec"

describe "Platform" do
  before do
    chrome_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome()
    firefox_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox()

    @chrome = Selenium::WebDriver.for(
      :remote,
      url: 'http://localhost:4444/wd/hub',
      desired_capabilities: chrome_capabilities
    )

    @firefox = Selenium::WebDriver.for(
      :remote,
      url: 'http://localhost:4444/wd/hub',
      desired_capabilities: firefox_capabilities
    )

    @chrome.get('http://google.com')
    @firefox.get('http://google.com')

    sleep(3)
  end

  after do
    @chrome.quit
    @firefox.quit
  end

  context "chrome" do
    it "checks title" do
      expect(@chrome.title).to eq('Google')
    end
  end

  context "firefox" do
    it "checks title" do
      expect(@firefox.title).to eq('Google')
    end
  end
end
