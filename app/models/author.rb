class Author < ApplicationRecord
    has_many :articles, dependent: :destroy
    has_many :drafts, dependent: :destroy
    has_many :lists, dependent: :destroy

    serialize :article_ids, Array
    serialize :following_ids, Array
    serialize :saved_ids, Array
    serialize :shared_lists, Array
end
