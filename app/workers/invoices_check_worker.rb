class InvoicesCheckWorker
  include Sidekiq::Worker

  def perform(*args)
    invoices = Invoice.expired.open
    invoices.map { |invoice| invoice.update_attribute :status, 'late' }
  end
end
