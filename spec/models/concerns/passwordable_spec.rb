require 'rails_helper'

RSpec.describe Passwordable, type: :concern do
  let(:user) { create(:user) }

  describe 'password methods' do
    it 'authenticates with correct password' do
      user.password = 'password123'
      user.save!
      expect(user.authenticate('password123')).to be_truthy
    end

    it 'fails with incorrect password' do
      user.password = 'password123'
      user.save!
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end
end





