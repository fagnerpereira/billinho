class Invoice < ApplicationRecord
  belongs_to :registration

  before_create :set_values

  default_scope { order(created_at: :asc) }

  private

  def set_values
    self.value = registration.amount / registration.bills_count
    self.expires_at = Time.local \
      registration.next_expiration_year,
      registration.next_expiration_month,
      registration.next_expiration_day
  end
end
