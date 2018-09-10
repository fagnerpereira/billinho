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


  context '#pay' do
    let(:current_date) { Time.local(2018, 9, 7).to_date }

    before { Timecop.freeze(current_date) }
    after { Timecop.return }

    context 'success' do
      subject(:invoice) { registration.invoices.create(expires_at: '10/10/2018', value: 200) }

      it { expect { invoice.pay }.to change { invoice.status }.from('open').to('paid') }
      it { expect { invoice.pay }.not_to change { invoice.value } }
    end

    context 'late' do
      subject(:invoice) { registration.invoices.create(expires_at: '6/9/2018', value: 200) }

      it { expect { invoice.pay }.to change { invoice.status }.from('open').to('paid') }
      it { expect { invoice.pay }.to change { invoice.value }.from(200).to(220) }
    end
  end

  context '#fine_amount' do
    let(:current_date) { Time.local(2018, 9, 7).to_date }

    before { Timecop.freeze(current_date) }
    after { Timecop.return }

    context 'no fine' do
      subject(:invoice) { registration.invoices.create(expires_at: '10/10/2018', value: 200) }

      it { expect(invoice.fine_amount).to eq(0) }
    end

    context 'late' do
      subject(:invoice) { registration.invoices.create(expires_at: '6/9/2018', value: 200) }

      it { expect(invoice.fine_amount).to eq(20.0) }
    end
  end
end
