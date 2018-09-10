require 'rails_helper'
RSpec.describe InvoicesCheckWorker, type: :worker do
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

  let!(:invoice) { registration.invoices.create(expires_at: '10/10/2018') }

  context 'expire day greater than current_day' do
    before do
      Timecop.freeze(2018, 10, 11)

      work = InvoicesCheckWorker.new
      work.perform

      invoice.reload
    end

    after { Timecop.return }

    it { expect(invoice.status).to eq('late') }
  end
end
