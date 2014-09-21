require 'nokogiri'  
require 'open-uri'  

url = "http://tsdr.uspto.gov/statusview/sn85609222"  
doc = Nokogiri::HTML(open(url))  
#puts doc.at_xpath('[@data-sectionTitle="Goods and Services"]'')  


url = "http://tsdr.uspto.gov/statusview/sn85609222"  
detaildoc = Nokogiri::HTML(open(url))  
detaildoc.xpath('//*[.="Application Filing Date:"]/../div[4]').text

url = "http://tsdr.uspto.gov/statusview/sn86396371"
doc = Nokogiri::HTML(open(url))  
doc.xpath("//*[contains(., 'NON-FINAL')]")


