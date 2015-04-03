require 'spec_helper'

describe ScreeningList::Part561Data do
  before { ScreeningList::Part561.recreate_index }
  let(:fixtures_dir) { "#{Rails.root}/spec/fixtures/screening_lists" }
  let(:fixtures_file) { "#{fixtures_dir}/treasury_consolidated/consolidated.xml" }
  let(:importer) { described_class.new(fixtures_file) }
  let(:expected) { YAML.load_file("#{fixtures_dir}/part561/results.yaml") }

  it_behaves_like 'an importer which can purge old documents'

  describe '#import' do
    it 'loads Part561 from specified resource' do
      expect(ScreeningList::Part561).to receive(:index) do |part561|
        expect(part561).to eq(expected)
      end
      importer.import
    end
  end
end