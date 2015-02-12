require 'mongo'

class ContentExplorerData
  include Importer

  #mongo_client = Mongo::MongoClient.new("54.68.10.157", 27017)
  mongo_client = Mongo::MongoClient.new('localhost', 27017)
  db = mongo_client.db("test")
  coll = db["infoSave"]
  ENDPOINT = coll.find.to_a.to_json


  COLUMN_HASH = {
    _id:               :id,
    TradeTopics:      :trade_topics,
    Region:           :region,
    SubRegion:        :sub_region,
    Country:          :country,
    Industry:         :industry,
    Sector:           :sector,
    SubSector:        :sub_sector,
    DocumentType:     :document_type,
    Content:          :content,
    VersionNumber:    :version_number,
    CreatedDate:      :created_date,
    CreatedBy:        :created_by,
    UpdatedDate:      :updated_date,
    UpdatedBy:        :updated_by,
  }.freeze

  def initialize(resource = ENDPOINT)
    @resource = resource
  end

  def import
    Rails.logger.info "Importing #{@resource}"
    doc = JSON.parse(open(@resource).read, symbolize_names: true)
    entries = doc.map { |entry_hash| process_entry_info entry_hash }
    ContentExplorer.index entries
  end

  private

  def process_entry_info(entry_hash)
    entry = remap_keys COLUMN_HASH, entry_hash
    entry[:content] = Sanitize.clean(entry[:content]) if entry[:content]
    entry[:created_date] = Date.parse(entry[:created_date]) if entry[:created_date]
    entry[:updated_date] = Date.parse(entry[:updated_date]) if entry[:updated_date]
    entry
  end
end
