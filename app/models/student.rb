class Student < ApplicationRecord
  has_many :registrations

  validates :name, :cpf, :gender, :payment_method, presence: true
  validates :name, :cpf, uniqueness: true
  validates :cpf, numericality: { only_integer: true }
  validates :gender, inclusion: { in: %w(M F) }
  validates :payment_method, inclusion: { in: %w(Boleto Cartão) }
end
