class Api::V2::ContentExplorersController < ApplicationController
  include Searchable
  search_by :q, :countries, :trade_topics, :industries
end
