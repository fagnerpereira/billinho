class Institution < ApplicationRecord
  has_many :registrations
  has_many :students, through: :registrations
  belongs_to :user

  validates :name, :cnpj, :kind, presence: true
  validates :name, :cnpj, :kind, uniqueness: true
  validates :cnpj, numericality: { only_integer: true }
  validates :kind, inclusion: { in: %w(university school nursery) }
end
