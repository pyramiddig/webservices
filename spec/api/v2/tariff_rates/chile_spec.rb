require 'spec_helper'

describe 'FTA Chile Tariff Rates API V2', type: :request do
  include_context 'V2 headers'
  include_context 'TariffRate::Chile data'

  describe 'GET /tariff_rates/search?sources=CL' do
    let(:params) { { sources: 'cl' } }
    before { get '/v2/tariff_rates/search', params, @v2_headers }

    context 'when search parameters are empty' do
      subject { response }
      it_behaves_like 'it contains all TariffRate::Chile results'
      it_behaves_like 'a successful search request'
    end

    context 'when q is specified' do
      let(:params) { { sources: 'cl', q: 'caballos' } }

      subject { response }
      it_behaves_like 'a successful search request'
      it_behaves_like "an empty result when a query doesn't match any documents", sources: 'cl'
      it_behaves_like 'it contains all TariffRate::Chile results that match "caballos"'
    end
  end
end
