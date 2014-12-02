require 'mechanize'

class ProofOfDelivery
  attr_reader :result

  def initialize(shipment_charge)
    mech = Mechanize.new
    account = UpsAccountNumber.where("number LIKE '%#{shipment_charge.account_number}'").first.ups_account
    page = log_into_ups_tracking_page(mech, account.username, account.pass, shipment_charge)

    #retrieve information from UPS Page
    parsed_page = Nokogiri::HTML page.body
    xpaths = UPS_XPATHS

    @result = {
      shipper: shipper,
      date_delivered: sanitize_scraped_text(parsed_page.xpath(xpaths[0]).children[3]),
      left_at:  sanitize_scraped_text(parsed_page.xpath(xpaths[1]).children[3]),
      signed_by: sanitize_scraped_text(parsed_page.xpath(xpaths[2]).children[3]),
      address: (sanitize_scraped_text(parsed_page.xpath(xpaths[3]).children[3]) + " " + sanitize_scraped_text(parsed_page.xpath(xpaths[3]).children[5])).gsub(/\s+/, " ").squeeze,
      multiple_packages: sanitize_scraped_text(parsed_page.xpath(xpaths[4]).children[0]).to_i,
      billed_on: sanitize_scraped_text(parsed_page.xpath(xpaths[5]).children[0]),
      type: sanitize_scraped_text(parsed_page.xpath(xpaths[6]).children[0]),
      weight: sanitize_scraped_text(parsed_page.xpath(xpaths[7]).children[0]),
      image: ups_encoded_image(mech, parsed_page),
    }
  end

  def log_into_ups_tracking_page(mech, username, password, tracking_number)
    page = mech.get 'https://www.ups.com/one-to-one/login?loc=en_US&returnto=https%3A%2F%2Fwwwapps.ups.com%2FWebTracking%2FreturnToDetails%3Floc%3Den_US&mcp=true'
    
    #login to UPS
    form = page.forms[1]
    form.uid = username
    form.password = password
    page = form.submit form.buttons.first

    #enter UPS tracking number
    form = page.forms[2]
    form.trackNums = tracking_number
    form.submit form.buttons.first
  end

  def ups_encoded_image(mech, parsed_page)
    img_tag = parsed_page.xpath('//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/img')
    return nil if img_tag.count == 0 || img_tag.attr('src').nil?
    img_file = mech.get img_tag.attr('src').value
    "data:image/png;base64,#{Base64.encode64 img_file.body}"
  end

  def sanitize_scraped_text(data)
    data.nil? ? nil : data.text.strip
  end

  UPS_XPATHS = ['//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[1]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[2]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[1]/fieldset/div/fieldset/div/dl[3]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[2]/div[2]/fieldset/div[2]/dl/dd',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[1]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[2]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[3]',
                '//*[@id="fontControl"]/fieldset/div[3]/fieldset/div/fieldset/div/fieldset/div[1]/div[3]/fieldset/div[2]/dl/dd[4]']
end
