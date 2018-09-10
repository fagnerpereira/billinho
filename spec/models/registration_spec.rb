require 'rails_helper'

RSpec.describe Registration, type: :model do
  let(:user) { User.create(email: 'alice@example.com') }
  let(:student) do
    Student.create \
      name: 'Alice Doe',
      birthday: '07/03/1994',
      phone_number: 1199999999,
      cpf: 41564684881,
      gender: 'F',
      payment_method: 'invoice'
  end
  let(:institution) do
    user.institutions.create \
      name: 'FIAP',
      cnpj: 123456789,
      kind: 'university'
  end

  let(:registration) do
    institution.registrations.create \
      amount: 1000,
      bills_count: 5,
      bill_expiry_day: 7,
      course_name: 'Administração',
      student: student
  end

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
