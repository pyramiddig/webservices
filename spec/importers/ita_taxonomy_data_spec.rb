require 'spec_helper'

describe ItaTaxonomyData do
  before { ItaTaxonomy.recreate_index }
  let(:fixtures_dir) { "#{Rails.root}/spec/fixtures/ita_taxonomies/" }
  let(:resource) { "#{fixtures_dir}/test_data.zip" }
  let(:importer) { ItaTaxonomyData.new(resource) }

  it_behaves_like 'an importer which can purge old documents'
  it_behaves_like 'a versionable resource'

  describe '#import' do
    let(:entry_hash) { YAML.load_file("#{File.dirname(__FILE__)}/ita_taxonomy/results.yaml") }

    it 'loads ita taxonomies entries from specified resource' do
      expect(ItaTaxonomy).to receive(:index) do |entries|
        expect(entries.size).to eq(8)
        expect(entries).to match_array entry_hash
      end
      importer.import
    end
  end
end
