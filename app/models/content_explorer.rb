class ContentExplorer
  extend Indexable

  self.settings = {
    index: {
      analysis: {
        analyzer:
                  { custom_analyzer:        {
                    tokenizer: 'standard',
                    filter:    %w(standard asciifolding lowercase snowball) },
                    title_keyword_analyzer: {
                      tokenizer: 'keyword',
                      filter:    %w(asciifolding lowercase) },
            },
      },
    },
  }.freeze

  self.mappings = {
    content_explorer: {
      _timestamp: {
        enabled: true,
        store:   true,
      },
      dynamic:    'false',
      properties: {
        id:              { type: 'string', analyzer: 'title_keyword_analyzer' },
        trade_topics:           { type: 'string', analyzer: 'title_keyword_analyzer' },
        region:           { type: 'string', analyzer: 'title_keyword_analyzer' },
        sub_region:       { type: 'string', analyzer: 'title_keyword_analyzer' },
        country:          { type: 'string', analyzer: 'title_keyword_analyzer' },
        industry:         { type: 'string', analyzer: 'title_keyword_analyzer' },
        sector:           { type: 'string', analyzer: 'title_keyword_analyzer' },
        sub_sector:       { type: 'string', analyzer: 'title_keyword_analyzer' },
        document_type:    { type: 'string', analyzer: 'title_keyword_analyzer' },
        content:          { type: 'string', analyzer: 'custom_analyzer' },
        version_number:   { type: 'integer'},
        created_date:     { type: 'date', format: 'YYYY-MM-dd' },
        created_by:       { type: 'string', analyzer: 'title_keyword_analyzer' },
        updated_date:     { type: 'date', format: 'YYYY-MM-dd' },
        updated_by:       { type: 'string', analyzer: 'title_keyword_analyzer' }
      },
    },
  }.freeze
end
