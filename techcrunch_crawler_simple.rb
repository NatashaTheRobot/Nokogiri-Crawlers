=begin
  The Techcrunch crawler crawls Mashable and gets the Title, URL, Date, and Author for each post
=end

require 'open-uri'
require 'nokogiri'
require 'date'
require 'cgi'

def get_post_details(doc)
  
  #get title and url
  title_and_url = []
  doc.css('h2.headline').each do |headline|
    details = headline.xpath('.//a')[0].attributes
    
    #url encoded
    url = CGI.escape( details['href'].value() )
    
    #title parsing
    title = details['title'].value()
    title = title.gsub(/\"/, '\'')
    title = CGI.escape( title )
    title_and_url << {'title' => title, 'url' => url}
  end
  
  #get author and date
  author_and_date = []
  doc.css('div.publication-info').each do |post|
    #author
    author_details = post.xpath('.//div')[0].children
    begin
      author = author_details.children[0].content
      author = CGI.escape(author)
    rescue Exception
      author = author_details[0].content
      author = CGI.escape(author)
    end
    
    #post date / time
    date_details = post.xpath('.//div')[1].children
    date_string = date_details[0].content
    begin
      date = DateTime.parse(date_string)
    rescue Exception
      date = Time.now - 86400
    end
    
    author_and_date << {'author' => author, 'date' => date}
  end
  
  #combine the title and url with author and date
  posts = []
  title_and_url.each.with_index do |post, i|
    post.store('publication_id', '4f0f8f4b9ff088c9a1000002')
    post.update(author_and_date[i])
    posts << post
  end
  
  #returns an array of hashes with details for each post
  posts
end

public
def crawl_techcrunch
  #keeps track of Techcrunch page number
  page = 1
  
  #loop through each page on Techcrunch and get the author, title, url, and date for each post
  loop do
    #get post details per page
    url = "http://techcrunch.com/page/#{page}/"
    doc = Nokogiri::HTML(open(url))
    posts = get_post_details(doc)
    p posts
    
    #you've crawled all the pages if the returned posts array is empty
    break if posts == []
    
    #move on to the next page
    page += 1
  end
end