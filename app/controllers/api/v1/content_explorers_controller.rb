class Api::V1::ContentExplorersController < ApplicationController
  include Searchable
  search_by :q, :countries, :sectors, :industries
end
