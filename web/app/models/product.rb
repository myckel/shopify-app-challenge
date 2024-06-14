class Product < ApplicationRecord
  # Relationships
  has_many :variants, dependent: :destroy

  # Validations
  validates :title, :price, :inventory_level, presence: true
end
