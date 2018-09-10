require 'rails_helper'

RSpec.describe Registration, type: :model do
  include_context 'registration'

  context '#generate_invoices' do
    before do
      registration.generate_invoices
    end

    it { expect(registration.invoices.count).to be(registration.bills_count) }
  end

  context '#next_invoice_expiration' do
    subject(:invoice_expiration) { registration.next_invoice_expiration }

    context 'expire day greater than current_day' do
      before { Timecop.freeze(2018, 9, 5) }
      after { Timecop.return }

      it { expect(invoice_expiration.day).to be(7) }
      it { expect(invoice_expiration.month).to be(10) }
      it { expect(invoice_expiration.year).to be(2018) }
    end

    context 'expire day equal than current_day' do
      before { Timecop.freeze(2018, 9, 7) }
      after { Timecop.return }

      it { expect(invoice_expiration.day).to be(7) }
      it { expect(invoice_expiration.month).to be(10) }
      it { expect(invoice_expiration.year).to be(2018) }
    end

    context 'expire day less than current_day' do
      before { Timecop.freeze(2018, 9, 10) }
      after { Timecop.return }

      it { expect(invoice_expiration.day).to be(10) }
      it { expect(invoice_expiration.month).to be(10) }
      it { expect(invoice_expiration.year).to be(2018) }
    end
  end
end
