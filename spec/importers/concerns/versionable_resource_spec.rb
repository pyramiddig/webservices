require 'spec_helper'

describe VersionableResource do
  before do
    class Mock
      include Indexable
      self.mappings = {
        name.typeize => {
          _timestamp: {
            enabled: true,
            store:   true,
          },
        },
      }
    end

    class MockData
      include Importable
      include VersionableResource
      def initialize(docs = nil)
        @docs = docs
      end

      def available_version
        Digest::SHA1.hexdigest(@docs.to_yaml)
      end

      def import
        model_class.index(@docs)
      end
    end

    class MockQuery < Query
      def generate_search_body
        {}
      end
    end

    Mock.recreate_index
  end

  after do
    Object.send(:remove_const, :Mock)
    Object.send(:remove_const, :MockData)
  end

  describe '#import' do
    it 'stores the time of import' do
      expect(Mock.stored_metadata).to eq({})
      MockData.new([{ id: 1, content: 'foo' }]).import
      expect(Mock.stored_metadata[:last_updated]).to_not be_nil
      expect(Mock.stored_metadata[:last_imported]).to_not be_nil
    end

    context 'when source is unchanged' do
      before do
        expect(Mock.stored_metadata).to eq({})
        MockData.new([{ id: 1, content: 'foo' }]).import
        Mock.update_metadata(Mock.stored_metadata[:version], '2000-01-01')
        MockData.new([{ id: 1, content: 'foo' }]).import
      end
      it 'updates only the time of import when source is unchanged' do
        expect(Mock.stored_metadata[:last_updated]).to eq('2000-01-01')
        expect(Mock.stored_metadata[:last_imported]).to_not eq('2000-01-01')
        expect(Mock.stored_metadata[:version]).to eq('29cb2c0fe72b5d841236ddf88e22371a58649717')
      end
    end

    context 'when old last_updated format is present in metadata' do
      before do
        expect(Mock.stored_metadata).to eq({})
        Mock._update_metadata(time: 'quite some time ago')
      end
      subject { Mock.stored_metadata }
      it 'renames the "time" field to "last_updated"' do
        expect(subject[:time]).to be_nil
        expect(subject[:last_updated]).to eq('quite some time ago')
      end
    end

    describe 'resource-versioning logic' do
      it 're-indexes when there is a new version available' do
        expect(Mock).to receive(:index).twice
        MockData.new([{ id: 1, content: 'foo' }]).import
        MockData.new([{ id: 2, content: 'bar' }]).import
      end

      it 'does not re-index an existing version' do
        expect(Mock).to receive(:index).once
        MockData.new([{ id: 1, content: 'foo' }]).import
        MockData.new([{ id: 1, content: 'foo' }]).import
      end
    end
  end
end
