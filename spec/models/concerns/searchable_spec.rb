require 'spec_helper'

describe Searchable do
  before(:all) do
    class MockModel
      include Indexable
      self.fetch_all_sort_by = 'foo'
      self.mappings = {
        name.typeize => {
          _timestamp: {
            enabled: true,
            store:   true,
          },
          properties: {
            foo: { type: 'string' },
          },
        },
      }
      def self.source
        {
          full_name: 'A mocked model',
          code:      'MModel',
        }
      end
      self.model_classes = [MockModel]
    end

    class MockModelQuery
      def initialize(_options); end
      def self.sources
        [MockModel]
      end
      def search_type
        nil
      end

      def generate_search_body
        {}
      end

      def offset
        0
      end

      def size
        2
      end

      def sort
        []
      end
    end

    MockModel.recreate_index
    MockModel.index((1..1_000).map { |i| { foo: "Bar #{i}" } })
  end

  before(:each) do
    MockModel.update_metadata(9989, 'a few minutes ago')
  end

  after(:all) do
    Object.send(:remove_const, :MockModel)
    Object.send(:remove_const, :MockModelQuery)
  end

  context 'Metadata handling' do
    describe '#stored_metadata' do
      subject { MockModel.stored_metadata }
      it 'has correct fields' do
        expect(subject.keys).to include(:version, :last_updated, :last_imported)
      end
    end

    describe '#touch_metadata' do
      subject { MockModel.stored_metadata }
      it 'updates only the import_time field' do
        MockModel.touch_metadata('just now')
        expect(subject).to eq(version: 9989, last_updated: 'a few minutes ago', last_imported: 'just now')
      end
    end

    describe '#update_metadata' do
      subject { MockModel.stored_metadata }
      it 'updates all fields' do
        MockModel.update_metadata(4321, 'NOW!')
        expect(subject).to eq(version: 4321, last_updated: 'NOW!', last_imported: 'NOW!')
      end
    end
  end

  describe '#fetch_all' do
    subject { MockModel.fetch_all }

    it 'returns the correct number of documents' do
      expect(subject).to be_a(Hash)

      hits = subject[:hits]

      expect(hits.count).to eq(1_000)
      expect(hits.first[:_source]).to be_a(Hash)

      expect(hits.find { |h| h.key?(:time) }).to be_nil

      # Sorted correctly?
      expect(hits.first(10)).to eq hits.first(10).sort { |x, y| x[:foo] <=> y[:foo] }
    end

    it 'response includes metadata' do
      expect(subject.keys).to include(:sources_used)
      expect(subject[:sources_used]).to eq([{ source_last_updated: 'a few minutes ago', last_imported: 'a few minutes ago', source: 'A mocked model' }])

      # too wide test for the description
      expect(subject.keys).to match_array([:total, :hits, :offset, :sources_used])
    end
  end

  describe '#search_for' do
    subject { MockModel.search_for({}) }

    it 'response includes metadata' do
      expect(subject.keys).to include(:sources_used)
      expect(subject[:sources_used]).to eq([{ source_last_updated: 'a few minutes ago', last_imported: 'a few minutes ago', source: 'A mocked model' }])

      # too wide test for the description
      expect(subject.keys).to match_array([:total, :max_score, :hits, :offset, :sources_used])
    end
  end

  describe '#index_meta' do
    subject { MockModel.index_meta.first }

    it 'contains correct fields' do
      expect(subject.keys).to include(:source, :source_last_updated, :last_imported)
    end
  end
end
