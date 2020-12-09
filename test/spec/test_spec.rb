require 'selenium-webdriver'
require 'rspec'

describe 'Platform' do
  before do
    chrome_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome()

    @chrome = Selenium::WebDriver.for(
      :remote,
      url: 'http://localhost:4444/wd/hub',
      desired_capabilities: chrome_capabilities
    )

    @url = "https://#{ENV['TF_VAR_domain_prefix']}.#{ENV['TF_VAR_vpn_hosted_zone_domain']}"

    @chrome.get(@url)

    sleep(3)
  end

  after do |example|
    if example.exception
      @chrome.save_screenshot("Test failed: \"#{example.description}\".png")
    end

    @chrome.quit
  end

  it 'redirects to login page' do
    expect(@chrome.current_url).to eq("#{@url}/login")
  end

  it 'can login to grafana' do
    @chrome.find_element(:name, 'user').send_keys(ENV['TF_VAR_grafana_admin_username'])
    @chrome.find_element(:name, 'password').send_keys(ENV['TF_VAR_grafana_admin_password'])
    @chrome.find_element(:css, '[aria-label="Login button"]').click
    sleep(2)

    expect(@chrome.title).to eq('Home - Grafana')
  end
end
