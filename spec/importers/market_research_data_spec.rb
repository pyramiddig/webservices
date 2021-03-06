require 'spec_helper'

describe MarketResearchData, vcr: { cassette_name: 'industry_mapping_client/market_research.yml' } do
  let(:resource) { "#{Rails.root}/spec/fixtures/market_research/source.txt" }
  let(:importer) { MarketResearchData.new(resource) }
  let(:expected) { YAML.load_file("#{File.dirname(__FILE__)}/market_research/expected_indexed_data.yaml") }

  it_behaves_like 'an importer which cannot purge old documents'
  it_behaves_like 'a versionable resource'
  it_behaves_like 'an importer which indexes the correct documents'
end
