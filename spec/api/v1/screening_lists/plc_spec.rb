require 'spec_helper'

describe 'Palestinian Legislative Council List API V1', type: :request do
  include_context 'ScreeningList::Plc data'

  describe 'GET /v1/consolidated_screening_list/plc/search' do
    let(:params) { {} }
    before { get '/v1/consolidated_screening_list/plc/search', params }

    context 'when search parameters are empty' do
      subject { response }
      it_behaves_like 'it contains all ScreeningList::Plc results'
      it_behaves_like 'a successful search request'
    end

    context 'when q is specified' do
      let(:params) { { q: 'heBron' } }
      subject { response }
      it_behaves_like 'a successful search request'
      it_behaves_like 'it contains all ScreeningList::Plc results that match "heBron"'
    end

    context 'when countries is specified' do
      subject { response }
      let(:params) { { countries: 'PS' } }
      it_behaves_like 'a successful search request'
      let(:source) { ScreeningList::Plc }
      let(:expected) { [5] }
      it_behaves_like 'it contains all expected results of source'
    end

    context 'when type is specified' do
      subject { response }
      let(:params) { { type: 'Individual' } }
      it_behaves_like 'a successful search request'
      it_behaves_like 'it contains all ScreeningList::Plc results that match type "Individual"'
    end
  end
end
