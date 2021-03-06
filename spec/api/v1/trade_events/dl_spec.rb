require 'spec_helper'

describe 'DL Trade Events API V1', type: :request do
  include_context 'TradeEvent::Dl data'

  describe 'GET /v1/trade_events/dl/search' do
    let(:params) { { size: 100 } }
    before { get '/v1/trade_events/dl/search', params }
    subject { response }

    context 'when search parameters are empty' do
      it_behaves_like 'a successful search request'
      it_behaves_like 'it contains all TradeEvent::Dl results'
    end

    context 'when q is specified' do
      let(:params) { { q: 'Bangladesh' } }
      it_behaves_like 'a successful search request'
      let(:source) { TradeEvent::Dl }
      let(:expected) { [0] }
      it_behaves_like 'it contains all expected results of source'
      it_behaves_like "an empty result when a query doesn't match any documents"
    end
  end
end
