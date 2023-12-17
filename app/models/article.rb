class Article < ApplicationRecord
    validates :title, uniqueness: true
    belongs_to :author
    belongs_to :topic
    has_one_attached :image

    serialize :comments, Array
    serialize :likes, Array
    serialize :states, Array
end
