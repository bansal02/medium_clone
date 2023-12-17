class Draft < ApplicationRecord
    validates :title, uniqueness: true
    belongs_to :author
    belongs_to :topic

    serialize :states, Array
end
