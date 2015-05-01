class Tag
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  field :n,   as: :name,                        type: String

  field :al,  as: :average_length,              type: Float
  field :xl,  as: :max_length,                  type: Float
  field :ml,  as: :min_length,                  type: Float
  field :vl,  as: :variance_length,             type: Float

  field :ah,  as: :average_size_high,           type: Float
  field :xh,  as: :max_size_high,               type: Float
  field :mh,  as: :min_size_high,               type: Float
  field :vh,  as: :variance_size_high,          type: Float

  field :aw,  as: :average_size_low,            type: Float
  field :xw,  as: :max_size_low,                type: Float
  field :mw,  as: :min_size_low,                type: Float
  field :vw,  as: :variance_size_low,           type: Float

  field :ae,  as: :average_view_counter,        type: Float
  field :xe,  as: :max_view_counter,            type: Float
  field :me,  as: :min_view_counter,            type: Float
  field :ve,  as: :variance_view_counter,       type: Float

  field :ac,  as: :average_comment_counter,     type: Float
  field :xc,  as: :max_comment_counter,         type: Float
  field :mc,  as: :min_comment_counter,         type: Float
  field :vc,  as: :variance_comment_counter,    type: Float

  field :ay,  as: :average_mylist_counter,      type: Float
  field :xy,  as: :max_mylist_counter,          type: Float
  field :my,  as: :min_mylist_counter,          type: Float
  field :vy,  as: :variance_mylist_counter,     type: Float

  field :tv,  as: :total_video_count,           type: Integer

  index name: 1
  index average_length: 1
  index average_size_high: 1
  index average_length: 1
  index average_size_low: 1
  index average_view_counter: 1
  index average_comment_counter: 1
  index average_mylist_counter: 1

  include Elasticsearch::Model
  include Elasticsearch::Model::Serializing::InstanceMethods

  self.__elasticsearch__.client = Elasticsearch::Client.new host: 'localhost'

  index_name    "nico-tags-#{Rails.env}"
  document_type "tag"

  # Elastic indexes
  settings index: { number_of_shards: 5 } do
    mappings do
      indexes :name, :boost =>  100, analyzer: "kuromoji"
    end
  end

  after_save do
    TagIndexingWorker.perform_async(:index, id.to_s)
  end

  after_destroy do
    TagIndexingWorker.perform_async(:index, id.to_s)
  end

  def as_indexed_json(option={})
    {
      id: id.to_s,
      name: name
    }
  end
end
