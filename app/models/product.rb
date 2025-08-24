class Product < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 500 }

  def to_s
    "#{name} (#{code})"
  end
end
