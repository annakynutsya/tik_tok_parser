require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'

class ParserService
  def initialize
    setup_driver
  end

  def parse_tiktok_data(search_query, quantity)
    url = generate_tiktok_url(search_query)
    @driver.get(url)
    scraped_data = fetch_users_data(search_query, quantity)
    @driver.quit
    scraped_data
  end

  private

  def setup_driver
    options = Selenium::WebDriver::Firefox::Options.new
    options.binary = '/usr/lib/firefox/firefox'
    @driver = Selenium::WebDriver.for :firefox, options: options
    @wait = Selenium::WebDriver::Wait.new(timeout: 180)
  end

  def generate_tiktok_url(search_query)
    base_url = search_query.include?('#') ? 'https://www.tiktok.com/tag/' : 'https://www.tiktok.com/search?q='
    "#{base_url}#{search_query.delete('#')}"
  end

  def fetch_users_data(search_query, quantity)
    scraped_data = []
    count = 0

    while count < quantity
      users_info = search_query.include?('#') ? fetch_hashtag_users_info : fetch_search_results_users_info
      scraped_data.concat(fetch_user_data(users_info, search_query, quantity - count))
      count = scraped_data.size
    end

    scraped_data
  end

  def fetch_hashtag_users_info
    @wait.until { @driver.find_elements(css: '.tiktok-ie5x9-DivCardAvatar.exdlci10') }
  end

  def fetch_search_results_users_info
    @wait.until { @driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }
  end

  def fetch_user_data(users_info, search_query, remaining_results)
    users_info[0...remaining_results].map do |user_info|
      username = extract_username(user_info, search_query)
      user_url = "https://www.tiktok.com/@#{username}"
      [username, scrape_user_info(user_url)].flatten
    end
  end

  def extract_username(user_info, search_query)
    css_selector = search_query.include?('#') ? '.tiktok-1gi42ki-PUserName.exdlci15' : '.tiktok-2zn17v-PUniqueId.etrd4pu6'
    user_info.find_element(css: css_selector).attribute('textContent')
  end

  def scrape_user_info(user_url)
    response = HTTParty.get(user_url)
    document = Nokogiri::HTML(response.body)

    followers_count = extract_user_followers(document)
    avg_views = calculate_average_views(document)
    description = extract_description(document)
    email = extract_email(description)
    social_accounts = extract_social_accounts(description)

    [followers_count, avg_views, description, email, social_accounts]
  end

  def extract_user_followers(document)
    followers_element = document.at_css('.tiktok-rxe1eo-DivNumber strong[title="Followers"]')
    followers_element&.text || ''
  end

  def calculate_average_views(document)
    avg_nums = document.css('.video-count')
    total_views = avg_nums.map { |el| el.text.to_f }.sum
    avg_views = total_views / avg_nums.size
    avg_views.round(2)
  end

  def extract_description(document)
    description_element = document.at_css('.tiktok-vdfu13-H2ShareDesc.e1457k4r3')
    description_element&.text || ''
  end

  def extract_email(description)
    email_regex = /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}\b/i
    description.scan(email_regex).join
  end

  def extract_social_accounts(description)
    social_media_regex = /\W(Twitter|Instagram|Snapchat|Skype|Discord|YouTube):?\s?-?\s?\(?-?@?(\w+)\)?/i
    social_accounts = description.scan(social_media_regex).map { |network, username| "#{network}: #{username}" }
    social_accounts.join(' ')
  end
end
