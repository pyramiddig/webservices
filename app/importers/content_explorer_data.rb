require 'mongo'

class ContentExplorerData
  include Importer

  def import
    mongo_client = Mongo::MongoClient.new('localhost', 27017)
    db = mongo_client.db("test")
    coll = db["infoSave"]
    doc = coll.find()
    articles = doc.map { |article_hash| process_article_info article_hash }
    ContentExplorer.index articles
  end

  private

  def process_article_info(article_hash)
    article                  = {}
    article[:mongo_id]       = article_hash["_id"].to_s
    article[:trade_topics]   = article_hash["TradeTopics"]
    article[:region]         = article_hash["Region"]
    article[:sub_region]     = article_hash["SubRegion"]
    article[:country]        = article_hash["Country"]
    article[:industry]       = article_hash["Industry"]
    article[:sector]         = article_hash["Sector"]
    article[:sub_sector]     = article_hash["SubSector"]
    article[:document_type]  = article_hash["DocumentType"]
    article[:content]        = Sanitize.clean(article_hash["Content"])
    article[:version_number] = article_hash["VersionNumber"]
    article[:created_date]   = Date.parse(article_hash["CreatedDate"].to_s)
    article[:updated_date]   = Date.parse(article_hash["UpdatedDate"].to_s)
    article[:created_by]     = article_hash["CreatedBy"]
    article[:updated_by]     = article_hash["UpdatedBy"]
    article
  end
end