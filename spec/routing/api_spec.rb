require 'spec_helper'

shared_examples 'routable request' do
  it 'is routable request' do
    expect(get: request_path).to be_routable
  end
end

describe 'routes for Trade Events' do
  context 'when version is not specified' do
    let(:request_path) { 'trade_events/search' }
    it_behaves_like 'routable request'

    it 'route to the first API trade_events version' do
      expect(get: request_path)
        .to route_to(controller: 'api/v2/trade_events/consolidated', action: 'search', format: :json)
    end
  end

  context 'when the version 1 is specified in url' do
    let(:request_path) { 'v1/trade_events/search' }

    it_behaves_like 'routable request'
    it 'routes to the API v1 trade_events controller version' do
      expect(get: request_path)
        .to route_to(controller: 'api/v1/trade_events/consolidated', action: 'search', format: :json)
    end
  end

  context 'when the version 2 is specified in url' do
    let(:request_path) { 'v2/trade_events/search' }

    it_behaves_like 'routable request'
    it 'routes to the API v2 trade_events controller version' do
      expect(get: request_path)
        .to route_to(controller: 'api/v2/trade_events/consolidated', action: 'search', format: :json)
    end
  end
end
