json.call(entry[:_source],
          :region, :sub_region, :country, :industry, :sector,
          :sub_sector, :document_type, :content, :version_number,
          :created_date, :created_by, :updated_date, :updated_by
)
