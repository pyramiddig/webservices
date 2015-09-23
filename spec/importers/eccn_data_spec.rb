require 'spec_helper'

describe EccnData, vcr: { cassette_name: 'importers/eccn.yml', record: :once } do
  before { Eccn.recreate_index }
  let(:fixtures_file) { "#{Rails.root}/spec/fixtures/eccns/eccns.csv" }
  let(:importer) { described_class.new(fixtures_file) }
  let(:expected) { YAML.load_file("#{File.dirname(__FILE__)}/eccn/results.yaml") }

  it_behaves_like 'an importer which can purge old documents'

  describe '#import' do
    it 'loads Eccns from specified resource' do
      expect(Eccn).to receive(:index) do |results|
        expect(results).to eq(expected)
      end
      importer.import
    end

    it 'fails on unrecognized headers' do
      bad_importer = described_class.new("#{Rails.root}/spec/fixtures/eccns/eccns_bad.csv")
      expect { bad_importer.import }.to raise_error
    end
  end

  describe '#eccn_to_url' do
    it 'handles "category X" case' do
      r = importer.send(:eccn_to_url, 'Category 0')
      expect(r).to eq('http://www.bis.doc.gov/index.php/forms-documents/doc_download/988-ccl0')
    end

    it 'handles "category X, part  Y" case' do
      r = importer.send(:eccn_to_url, 'Category 5, Part  2 Note 3 (b)')
      expect(r).to eq('http://www.bis.doc.gov/index.php/forms-documents/doc_download/950-ccl5-pt1')
    end

    it 'ignores other notes' do
      r = importer.send(:eccn_to_url, 'see product group D for controls in each category')
      expect(r).to eq(nil)
    end

    it 'converts every leading-digit category correctly' do
      examples = { '0A981'    => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/988-ccl0',
                   '1C351d2'  => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/989-ccl1',
                   '2A001c'   => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/734-ccl2',
                   '3B001f1'  => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/990-ccl3',
                   '4A003e'   => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/1055-ccl4',
                   '5A002d'   => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/951-ccl5-pt2',
                   '5D001d'   => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/950-ccl5-pt1',
                   '6A008e'   => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/952-ccl6',
                   '7A002'    => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/1089-ccl7',
                   '8A002o3a' => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/863-category-8-marine',
                   '9A610y3'  => 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/991-ccl9' }
      examples.each do |code, url|
        expect(importer.send(:eccn_to_url, code)).to eq(url)
      end
    end
  end
end
