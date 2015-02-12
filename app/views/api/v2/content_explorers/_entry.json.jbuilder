json.call(entry[:_source],
          :id, :trade_topics, :region, :sub_region, :country, :industry, :sector,
          :sub_sector, :document_type, :content, :version_number,
          :created_date, :created_by, :updated_date, :updated_by
)
