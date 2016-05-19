require 'net/http'

class NewsFeedService
  class RedirectOverflow < StandardError; end
  attr_accessor :url, :body, :response, :redirect_limit, :store_service

  def initialize(url, limit=3)
    @url, @redirect_limit = url, limit
    @store_service = StoreService.new
    resolve
  end

  def resolve
    raise RedirectOverflow if @redirect_limit < 0

    @response = Net::HTTP.get_response(URI(@url))

    if @response.header.class.ancestors.include?(Net::HTTPRedirection)
      html_res = Nokogiri::HTML(@response.body)
      @url = html_res.xpath("//a").first.attributes["href"].value
      @redirect_limit -= 1

      resolve
    end

    @body = @response.body
  end

  def zip_urls
    zip_urls = []
    html_doc = Nokogiri::HTML(@body)
    html_doc.xpath("//a").each do |zip_node|
      if zip_node.attributes["href"]
        zip_urls << zip_node.attributes["href"].value
      end
    end
    zip_urls
  end

  def update_news_articles
    zip_urls.each do |zip_url|
      begin
        uri = URI(@url + zip_url.lstrip.rstrip)
        zip_res = Net::HTTP.get_response(uri)
        Zip::InputStream.open(StringIO.new(zip_res.body)) do |io|
          print "processing.. #{zip_url}\n"
          while(entry = io.get_next_entry) do
            xml = Nokogiri::XML(io.read)
            news_hash = Hash.from_xml(xml.to_s)
            @store_service.store(entry.name, news_hash)
          end
        end
      rescue URI::InvalidURIError
        next
      end
    end
  end
end
