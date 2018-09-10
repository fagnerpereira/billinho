class Invoice < ApplicationRecord
  belongs_to :registration

  validates :status, inclusion: { in: %w(open late paid) }

  default_scope { order(created_at: :asc) }

  scope :expired, -> { where('expires_at <= ?', Time.zone.now) }
  scope :open, -> { where(status: 'open') }
  scope :late, -> { where(status: 'late') }
  scope :paid, -> { where(status: 'paid') }

  def pay
    if paid?
      errors.add(:status, :not_open)
      false
    else
      self.status = 'paid'
      self.value += fine_amount
      self.save
    end
  end

  def fine_amount
    fine = 0.1 * value

    return (Time.zone.now.to_date - expires_at).to_i * fine if expired?
    0
  end

  private

  def expired?
    expires_at <= Time.zone.now
  end

  def paid?
    status == 'paid'
  end
end
