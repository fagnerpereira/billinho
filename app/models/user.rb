class User < ApplicationRecord
  has_many :institutions

  before_create :set_access_token

  private

  def set_access_token
    self.access_token = SecureRandom.uuid
  end
end
