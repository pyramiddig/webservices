require 'spec_helper'

describe 'FTA Honduras Tariff Rates API V1', type: :request do
  include_context 'TariffRate::Honduras data'

  describe 'GET /v1/tariff_rates/search?sources=HN' do
    let(:params) { { sources: 'hn' } }
    before { get '/v1/tariff_rates/search', params }

    context 'when search parameters are empty' do
      subject { response }
      it_behaves_like 'it contains all TariffRate::Honduras results'
      it_behaves_like 'a successful search request'
    end

    context 'when q is specified' do
      let(:params) { { sources: 'hn', q: 'horses' } }

      subject { response }
      it_behaves_like 'a successful search request'
      it_behaves_like "an empty result when a query doesn't match any documents", sources: 'hn'
      it_behaves_like 'it contains all TariffRate::Honduras results that match "horses"'
    end
  end
end
