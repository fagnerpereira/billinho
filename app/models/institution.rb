class Institution < ApplicationRecord
  has_many :registrations
  belongs_to :user

  validates :name, :cnpj, :kind, presence: true
  validates :name, :cnpj, :kind, uniqueness: true
  validates :cnpj, numericality: { only_integer: true }
  validates :kind, inclusion: { in: %w(Universidade Escola Creche) }
end
