class ContentExplorerQuery < Query
  def initialize(options = {})
    super
    @q = options[:q] if options[:q].present?
    @countries = options[:countries].downcase.split(',') if options[:countries].present?
    @sectors = options[:sectors].downcase.split(',') if options[:sectors].present?
    @industries = options[:industries].downcase.split(',') if options[:industries].present?
  end

  private

  def generate_query(json)
    multi_fields = %i(content)
    json.query do
      json.bool do
        json.must do
          json.child! { generate_multi_match(json, multi_fields, @q) } if @q
        end
      end
    end if @q
  end

  def generate_filter(json)
    json.filter do
      json.bool do
        json.must do
          json.child! { json.terms { json.country @countries } } if @countries
          json.child! { json.terms  { json.sector @sectors }  } if @sectors
          json.child! { json.terms  { json.industry @industries }  } if @industries
        end
      end
    end if @countries ||  @sectors || @industries
  end
end
