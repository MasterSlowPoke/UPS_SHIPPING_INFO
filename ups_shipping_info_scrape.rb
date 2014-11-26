require 'selenium-webdriver'


class UpsInfo

  def initialize(username, password, tracking_number)
    @@br = Selenium::WebDriver.for :chrome
    @@br.get 'https://www.ups.com/one-to-one/login?loc=en_US&returnto=https%3A%2F%2Fwwwapps.ups.com%2FWebTracking%2FreturnToDetails%3Floc%3Den_US&mcp=true'
    
    @@br.find_element(:id, 'repl_id1').send_key(username)
    @@br.find_element(:id, 'repl_id4').send_key(password)
    @@br.find_element(:id, 'submitBtn').click()
    @@br.find_element(:id, 'trackNums').send_key(tracking_number)
    @@br.find_element(:name, 'track.x').click()
    
  end
  
  
  def get_info()
    wait = Selenium::WebDriver::Wait.new(:timeout => 10) 

    xpaths = ['//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[1]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[2]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[3]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[2]/div[2]/fieldset/div[2]/dl/dd',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[1]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[2]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[3]',
              '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[4]']
    
    wait.until {@@br.find_element(:xpath, xpaths[7])}
    
    basic_information = []
    xpaths.each do |path|
      basic_information << @@br.find_element(:xpath, path)
    end
    
    hash_info = {}
    
    hash_info[:date_delivered]    = basic_information[0].text.partition(":\n").last.partition(' at ').first
    hash_info[:time_delivered]    = basic_information[0].text.partition(":\n").last.partition(' at ').last
    hash_info[:left_at]           = basic_information[1].text.partition(":\n").last
    hash_info[:signed_by]         = basic_information[2].text.partition(":\n").last
    hash_info[:address]           = basic_information[3].text.partition(":\n").last
    hash_info[:multiple_packages] = basic_information[4].text
    hash_info[:billed_on]         = basic_information[5].text
    hash_info[:type]              = basic_information[6].text
    hash_info[:weight]            = basic_information[7].text
    
    pic_name = hash_info[:signed_by]
    hash_info[:signature_pic]     = 'signatures/' + pic_name + '.png'
    
    image = @@br.find_element(:xpath, '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/img')
    link = image.attribute("src")
    @@br.get(link)
    
    pic = @@br.save_screenshot('signatures/' + pic_name + '.png')
    
    return hash_info
  end
  
  
  def quit_browser()
    @@br.quit
  end
  
end

# username = 'pinchpro'
# password = 'Pinchme123'
# tracking = '1Z5560TT0393090598'
#
# test = UpsInfo.new(username, password, tracking)
# info = test.get_info()
#
# puts info
#
# test.quit_browser()