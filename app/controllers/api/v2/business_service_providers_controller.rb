class Api::V2::BusinessServiceProvidersController < ApiController
  search_by :q, :ita_offices, :company_names, :company_descriptions, :categories
end
