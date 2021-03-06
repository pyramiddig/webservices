require 'spec_helper'

describe Webservices::Application do
  describe '.model_classes' do
    subject { described_class.model_classes }

    it { is_expected.to include(ScreeningList::Dpl) }
    it { is_expected.to include(MarketResearch) }

    it { is_expected.not_to include(ScreeningList::Consolidated) }
    it { is_expected.not_to include(TradeEvent::Mappable) }
    it { is_expected.not_to include(ParatureFaqData) }
  end
end
