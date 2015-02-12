class Api::V2::ContentExplorersController < ApplicationController
  include Searchable
  search_by :q, :countries, :sectors, :industries
end
