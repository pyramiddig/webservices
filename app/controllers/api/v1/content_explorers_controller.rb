class Api::V1::ContentExplorersController < ApplicationController
  include Searchable
  search_by :q, :countries, :trade_topics, :industries
end
