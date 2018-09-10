class Registration < ApplicationRecord
  belongs_to :student
  belongs_to :institution

  has_many :invoices

  validates :student, :institution, uniqueness: { scope: [:student_id, :institution_id] }
  validates :amount, :bills_count, :bill_expiry_day, :course_name, presence: true
  validates :amount, :bills_count, numericality: { greater_than: 0 }
  validates :bill_expiry_day, numericality: { greater_than: 0, less_than: 31 }

  def generate_invoices
    bills_count.times { invoices.create(value: invoice_value, expires_at: next_invoice_expiration) }
  end

  def next_invoice_expiration
    Time.local \
      next_expiration_year,
      next_expiration_month,
      next_expiration_day
  end

  private
  def invoice_value
    amount / bills_count
  end

  def next_expiration_year
    last_invoice = invoices.reload.last

    if last_invoice
      last_invoice.expires_at.next_month.year
    else
      Time.zone.now.next_month.year
    end
  end

  def next_expiration_month
    last_invoice = invoices.reload.last

    if last_invoice
      last_invoice.expires_at.next_month.month
    else
      Time.zone.now.next_month.month
    end
  end

  def next_expiration_day
    current_day = Time.zone.now.day
    difference = bill_expiry_day - current_day

    if difference <= 0
      Time.zone.now.day
    else
      difference.days.from_now.day
    end
  end
end
