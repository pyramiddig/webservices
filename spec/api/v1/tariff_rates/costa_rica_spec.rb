require 'spec_helper'

describe 'FTA Costa Rica Tariff Rates API V1', type: :request do
  include_context 'TariffRate::CostaRica data'

  describe 'GET /v1/tariff_rates/search?sources=CR' do
    let(:params) { { sources: 'cr' } }
    before { get '/v1/tariff_rates/search', params }

    context 'when search parameters are empty' do
      subject { response }
      it_behaves_like 'it contains all TariffRate::CostaRica results'
      it_behaves_like 'a successful search request'
    end

    context 'when q is specified' do
      let(:params) { { sources: 'cr', q: 'horses' } }

      subject { response }
      it_behaves_like 'a successful search request'
      it_behaves_like 'it contains all TariffRate::CostaRica results that match "horses"'
      it_behaves_like "an empty result when a query doesn't match any documents", sources: 'cr'
    end
  end
end
