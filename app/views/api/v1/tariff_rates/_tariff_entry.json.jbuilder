json.call(entry[:_source],
          :source_id, :tariff_line, :subheading_description, :hs_6, :base_rate,
          :base_rate_alt, :final_year, :tariff_rate_quota, :tariff_rate_quota_note,
          :tariff_eliminated, :ag_id, :partner_name,
          :reporter_name, :staging_basket,
          :partner_start_year, :reporter_start_year, :partner_agreement_name,
          :reporter_agreement_name, :partner_agreement_approved,
          :reporter_agreement_approved, :quota_name, :rule_text, :link_text, :link_url,
          :annual_rates, :alt_annual_rates, :source
         )
