require 'selenium-webdriver'

br = Selenium::WebDriver.for :chrome

br.get 'http://www.ups.com/WebTracking/track?loc=en_US&WT.svl=PriNav'
