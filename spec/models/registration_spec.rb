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
end
