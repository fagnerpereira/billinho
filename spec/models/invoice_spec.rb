require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:user) { User.create(email: 'alice@example.com') }
  let(:student) do
    Student.create \
      name: 'Alice Doe',
      birthday: '07/03/1994',
      phone_number: 1199999999,
      cpf: 41564684881,
      gender: 'F',
      payment_method: 'Boleto'
  end
  let(:institution) do
    user.institutions.create \
      name: 'FIAP',
      cnpj: 123456789,
      kind: 'Universidade'
  end

  let(:registration) do
    institution.registrations.create \
      amount: 1000,
      bills_count: 5,
      bill_expiry_day: 6,
      course_name: 'Administração',
      student: student
  end

  subject(:invoice) { registration.invoices.create }

  it { expect(invoice.value).to be(registration.amount/registration.bills_count) }
  it { expect(invoice.status).to eq('open') }

  context 'expire day greater than current_day' do
    before { Timecop.freeze(2018, 9, 5) }
    after { Timecop.return }

    it { expect(invoice.expires_at.day).to be(6) }
    it { expect(invoice.expires_at.month).to be(10) }
    it { expect(invoice.expires_at.year).to be(2018) }
  end

  context 'expire day equal than current_day' do
    before { Timecop.freeze(2018, 9, 6) }
    after { Timecop.return }

    it { expect(invoice.expires_at.day).to be(6) }
    it { expect(invoice.expires_at.month).to be(10) }
    it { expect(invoice.expires_at.year).to be(2018) }
  end

  context 'expire day less than current_day' do
    before { Timecop.freeze(2018, 9, 10) }
    after { Timecop.return }

    it { expect(invoice.expires_at.day).to be(10) }
    it { expect(invoice.expires_at.month).to be(10) }
    it { expect(invoice.expires_at.year).to be(2018) }
  end
end
