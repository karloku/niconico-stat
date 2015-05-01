class TagIndexingWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'nico-elasticsearch', retry: false

  Client = Tag.__elasticsearch__.client
  def perform(operation, tag_id)

    case operation.to_s
    when /index/
      record = Tag.find(tag_id["$oid"])
      Client.index index: Tag.index_name, type: Tag.document_type, id: tag_id, body: record.as_indexed_json
    when /delete/
      Client.delete index: Tag.index_name, type: Tag.document_type, id: tag_id
    else 
      raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
