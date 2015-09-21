require 'open-uri'
require 'csv'

module TradeEvent
  class UstdaData
    include Importable
    include ::VersionableResource

    # Test endpoint, might need to change this later
    ENDPOINT = 'http://dev-ustda-drupal-dev.gotpantheon.com/api/events/xml'

    SINGLE_VALUED_XPATHS = {
      event_name:         './Title',
      start_date:         './Start-Date',
      end_date:           './End-Date',
      event_time:         './End-Time',
      cost:               './Cost',
      cost_currency:      './Cost-Currency',
      registration_link:  './Registration-Link',
      registration_title: './Registration-Title',
      description:        './Body',
      industry:           './Industry',
      url:                './Learn-More-URL',
      first_name:         './First-Name',
      last_name:          './Last-Name',
      post:               './Post',
      person_title:       './Person_Title',
      phone:              './Phone',
      email:              './Email'
    }.freeze

    VENUE_XPATHS = {
      venue:   './Venue-%d',
      city:    './City-%d',
      state:   './State-%d',
      country: './Country-%d'
    }

    def loaded_resource
      @loaded_resource ||= open(@resource, 'r:utf-8').read
    end

    def import
      doc = Nokogiri::XML(loaded_resource)
      events = doc.xpath('//node').map do |event| 
        event = process_entry(event)
      end.compact
      Ustda.index(events)
    end

    private

    def process_entry(entry)
      event = extract_fields(entry, SINGLE_VALUED_XPATHS)

      #%i(start_date end_date).each do |field|
      #  format = (event[field] =~ /\/\d{2}$/) ? '%m/%d/%y' : '%m/%d/%Y'
      #  event[field] = Date.strptime(event[field], format).iso8601 rescue nil if event[field]
      #end

      #event[:cost], event[:cost_currency] = cost(entry) if entry[:cost]

      event[:venues] = venues(entry)
      event[:event_type] = nil
      event[:event_source] = model_class.source[:code]

      event
    end

    def cost(entry)
      cost = Monetize.parse(entry[:cost])
      [cost.to_f, cost.currency_as_string]
    end

    def venues(entry)
      (1..3).map do |venue_number|
        venue_xpaths = {}
        VENUE_XPATHS.each do |key, value|
          venue_xpaths[key] = value % venue_number
        end
        extract_fields(entry, venue_xpaths)
      end
    end

    #def venues(entry)
    #  (1..3).map do|id|
    #    fields = %w(country state city venue).map { |fname| "#{fname}#{id}".to_sym }
    #    venue = entry
    #            .slice(*fields)
    #            .map do |k, v|
    #      { k.to_s.chop => v.blank? ? '' : v.strip }
    #    end
    #            .reduce(:merge)
    #            .symbolize_keys
    #    venue[:country] = lookup_country(venue[:country]) unless venue[:country].blank?
    #    venue.values.all?(&:blank?) ? nil : venue
    #  end.compact
    #end
  end
end
