require 'mechanize'
require 'nokogiri'
require 'pry'
require 'open-uri'  


class SearchController < ApplicationController
  def index
  	userquery = params[:searchquery]
  	if(userquery)
		urlprefix = 'http://tmsearch.uspto.gov'
		agent = Mechanize.new
		agent.get(urlprefix+'/bin/gate.exe?f=login&p_lang=english&p_d=trmk')
		searchpage = agent.page.link_with(:text => "Word and/or Design Mark Search (Free Form)").click()
		searchform = searchpage.forms.first
		state = searchform["state"]

		@userquery = userquery
		searchquery = '('+userquery+')[bi,ti,tl,mp]'
		#searchquery = '(legal hack*)[bi,ti,tl,mp] and 041[ic] and principal[rg] and live[ld]'
		results = agent.post(urlprefix+'/bin/gate.exe', {
		  "f" => "toc",  "p_search" => "search", "a_search" => "Submit+Query",
		  "state" => state, "p_L" => "10",
		  "p_s_ALL" => searchquery
		})

		agent.get(urlprefix+'/bin/gate.exe?state='+state+'&f=logout&a_logout=Logout');

		doc = Nokogiri::HTML.parse(results.content)

		@tm_items = doc.xpath('/html/body/table[@border=2]/tr')
		@another_items = []
		@tm_items.each do |tr|
			sn = tr.at_xpath('td[2]').content
			detailurl = "http://tsdr.uspto.gov/#caseNumber="+sn+"&caseType=SERIAL_NO&searchType=statusSearch"
			imgurl = "http://tsdr.uspto.gov/img/"+sn+"/large"

			detaildoc = Nokogiri::HTML(open("http://tsdr.uspto.gov/statusview/sn"+sn))  
			gs = detaildoc.xpath('//*[@data-sectiontitle="Goods and Services"]/../../div/div/div[2]/div/div[2]').text.strip!
			reg_num = detaildoc.xpath('//*[@id="summary"]//*[.="US Registration Number:"]/../div[2]').text
			owner = detaildoc.xpath('//*[.="Owner Name:"]/../div[2]').text.strip!
			office_action = detaildoc.xpath("//*[contains(., 'NON-FINAL')]").count > 0 ? "YES" : "NO"
			
			filing_date = detaildoc.xpath('//*[.="Application Filing Date:"]/../div[4]').text
			reg_date = detaildoc.xpath('//*[.="Registration Date:"]/../div[4]').text
			disclaimer = detaildoc.xpath('//*[.="Disclaimer:"]/../div[2]').text

			class_list = detaildoc.xpath('//*[.="International Class(es):"]/../div[2]').text
			@another_items << {:name => tr.at_xpath('td[4]').content,
							   :rownum => tr.at_xpath('td[1]').content,
							   :sn => sn,
							   :imgurl => imgurl,
							   :detailurl => detailurl,
							   :filing_date => filing_date,
							   :reg_date => reg_date, :disclaimer => disclaimer,
							   :gs => gs, :class_list => class_list,
							   :owner => owner, :office_action => office_action,
							   :reg_num => reg_num}
		end
	end
  end
end

#http://tsdr.uspto.gov/#caseNumber=86183549&caseType=SERIAL_NO&searchType=statusSearch
#http://tsdr.uspto.gov/statusview/sn86383176
#http://tsdr.uspto.gov/docsview/proceedings/85609222
#http://tsdr.uspto.gov/docsview/assignments/85609222
#http://tsdr.uspto.gov/docsview/sn85609222
#http://tsdr.uspto.gov/img/85609222/large

# //*[@id="data_container"]/div[4]/div/div/div[2]/div/div[1]