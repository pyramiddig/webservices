require 'open-uri'

class UrlMapper
  include Indexable

  NAME = 'UrlMappings'

  self.mappings = {
    url_mapping: {
      dynamic:    'false',
      properties: {
        link:         { type: 'string', index: 'not_analyzed' },
        long_url:     { type: 'string', index: 'not_analyzed' },
        title:        { type: 'string', analyzer: 'standard' },
        description:  { type: 'string', analyzer: 'standard' }
      },
    },
  }.freeze

  def self.index_name
    @index_name ||= [ES::INDEX_PREFIX, NAME.indexize].join(':')
  end

  def self.index_type
    @index_type ||= NAME.typeize
  end

  def self.process_url(url_string, title, description)
    encoded_url = CGI.escape(url_string)
    bitly_api_request = "https://api-ssl.bitly.com/v3/user/link_save?access_token=#{Rails.configuration.bitly_api_token}&longUrl=#{encoded_url}&title=#{title}"
    indexable_json = {
        id: Digest::SHA1.hexdigest(url_string), 
        long_url: url_string, 
        title: title, 
        description: description
      }

    search_result = search_for_url(url_string)[:hits]

    if search_result.count == 0
      short_link = call_bitly_api(bitly_api_request, url_string)
      index [indexable_json.merge({link: short_link})]
      return short_link
    elsif search_result.count == 1
      if (search_result.first[:title] == title && search_result.first[:description] == description)
        return search_result.first[:link]
      else 
        short_link = call_bitly_api(bitly_api_request, url_string)
        update [indexable_json.merge({link: short_link})]
        return short_link
      end
    else
      raise "More than 1 search result, entries should be unique by long_url!"
    end

  end

  def self.call_bitly_api(request_string, url_string)
    sleep 5
    response = JSON.parse(open(request_string).read)

    return url_string if response["status_code"] == '500'

    while (response["status_txt"] == "RATE_LIMIT_EXCEEDED" )#|| response["status_txt"] == "ALREADY_A_BITLY_LINK")
      puts "Rate limit exceeded, pausing momentarily..."
      sleep 60
      response = JSON.parse(open(request_string).read)
    end

    response["data"]["link_save"]["link"]
  end

  def self.search_for_url(url_string)
    search_options = {
      index: index_name,
      type:  index_type,
      body:  generate_search_body(url_string)
    }

    hits = ES.client.search(search_options)['hits'].deep_symbolize_keys
  end

  def self.generate_search_body(url_string)
    Jbuilder.encode do |json|
      json.filter do
        json.bool do
          json.must do
            json.child! { json.term { json.long_url url_string } }
          end
        end
      end
    end
  end

end