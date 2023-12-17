class Topic < ApplicationRecord
    has_many :articles, dependent: :destroy
    has_many :drafts, dependent: :destroy
    serialize :article_ids, Array
end
