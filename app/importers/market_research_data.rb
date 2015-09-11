require 'csv'
require 'open-uri'

class MarketResearchData
  include Importable
  include VersionableResource

  ENDPOINT = 'http://mr.export.gov/nextgen/ng.txt'

  COLUMN_HASH = {
    id:       :id,
    country:  :countries,
    descrip:  :description,
    expdate:  :expiration_date,
    industry: :industries,
    origform: :report_type,
    ttitle:   :title,
    doc:      :url,
  }

  REPORT_TYPE_HASH = {
    'bmr11' => 'Best Market Research',
    'ccg1'  => 'Country Commercial Guide',
  }

  def loaded_resource
    @loaded_resource ||= open(@resource, 'r:windows-1252:utf-8').read
  end

  def import
    entries = []
    @url_count = 0
    MrlParser.foreach(loaded_resource) do |source_hash|
      entries << process_source_hash(source_hash)
    end
    puts @url_count
    #MarketResearch.index entries
  end

  private

  def process_source_hash(source_hash)
    entry = remap_keys(COLUMN_HASH, source_hash)
    entry[:countries] = entry[:countries].present? ? extract_countries(entry[:countries]) : []
    entry[:expiration_date] = parse_date(entry[:expiration_date])
    entry[:industries] = extract_industries(entry[:industries])
    entry[:report_type] = detect_report_type(entry[:report_type])
    entry[:url] = "http://mr.export.gov/docs/#{entry[:url]}" if entry[:url].present?
    @url_count += 1 if entry[:url].present?
    #sleep 1
    entry
  end

  def extract_countries(countries_str)
    countries = str_to_a(countries_str)
    countries.map { |country| lookup_country(country) }.compact.sort
  end

  def str_to_a(input_str, delimiter = '|')
    input_str.split(delimiter).map do |item|
      item.present? ? item.squish : nil
    end.compact
  end

  def extract_industries(industries_str)
    industries = str_to_a(industries_str || '')
    { original: industries,
      mapped:   industries.map { |i| normalize_industry(i) }.compact }
  end

  def detect_report_type(report_type_str)
    report_type = REPORT_TYPE_HASH[report_type_str]
    report_type ||= 'Market Research Report'
    report_type
  end
end
