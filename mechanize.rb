require 'mechanize'
require 'nokogiri'

urlprefix = 'http://tmsearch.uspto.gov'
agent = Mechanize.new
agent.get(urlprefix+'/bin/gate.exe?f=login&p_lang=english&p_d=trmk')
searchpage = agent.page.link_with(:text => "Word and/or Design Mark Search (Free Form)").click()
searchform = searchpage.forms.first
state = searchform["state"]

searchquery = '(legal hack*)[bi,ti,tl,mp] and 041[ic] and principal[rg] and live[ld]'
results = agent.post(urlprefix+'/bin/gate.exe', {
  "f" => "toc",  "p_search" => "search", "a_search" => "Submit+Query",
  "state" => state, "p_L" => "20",
  "p_s_ALL" => searchquery
})

doc = Nokogiri::HTML.parse(results.content)
# doc.search('//table[@border=2]/tbody/tr', 'td[4] > a').each do |a_tag|
#   puts a_tag.content
# end

doc.xpath('/html/body/table[@border=2]/tr').each do |tr|
  puts tr.at_xpath('td[2]').content + " " + tr.at_xpath('td[4]').content
end

agent.get(urlprefix+'/bin/gate.exe?state='+state+'&f=logout&a_logout=Logout');


#http://tsdr.uspto.gov/statusview/sn86383176
#http://tsdr.uspto.gov/docsview/proceedings/85609222
#http://tsdr.uspto.gov/docsview/assignments/85609222
#http://tsdr.uspto.gov/docsview/sn85609222
#http://tsdr.uspto.gov/img/85609222/large