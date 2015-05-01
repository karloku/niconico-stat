class Video
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>
  field :v, as: :video_id,        type: String
  field :t, as: :thread_id,       type: Integer
  field :i, as: :title,           type: String
  field :d, as: :description,     type: String
  field :b, as: :thumbnail_url,   type: String
  field :u, as: :upload_time,     type: DateTime
  field :l, as: :length,          type: Integer
  field :m, as: :movie_type,      type: String
  field :h, as: :size_high,       type: Integer
  field :w, as: :size_low,        type: Integer
  field :e, as: :view_counter,    type: Integer
  field :c, as: :comment_counter, type: Integer
  field :y, as: :mylist_counter,  type: Integer

  has_and_belongs_to_many :tags, inverse_of: nil

  validates_presence_of :video_id

  index({video_id: 1}, {background: true, unique: true})
  index({title: 1}, {background: true})
  index({upload_time: 1}, {background: true})
  index({tag_ids: 1}, {background: true})
end
