class List < ApplicationRecord
    validates :name, uniqueness: true
    belongs_to :author
    serialize :article_ids, Array
    serialize :shared_with, Array
end
