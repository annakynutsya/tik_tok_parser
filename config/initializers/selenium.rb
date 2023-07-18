require 'capybara'
require 'selenium-webdriver'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome, # or :firefox, :safari, etc. based on your preference
    options: Selenium::WebDriver::Chrome::Options.new(args: ['headless', 'disable-gpu'])
  )
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium
