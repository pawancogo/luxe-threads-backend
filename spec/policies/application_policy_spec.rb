require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:admin_user) { create(:user, :admin) }
  let(:customer_user) { create(:user) }
  let(:record) { double('record') }

  describe 'inheritance' do
    it 'inherits from a policy base class' do
      expect(ApplicationPolicy.superclass).to be_present
    end
  end

  describe 'initialization' do
    it 'sets user and record' do
      policy = ApplicationPolicy.new(admin_user, record)
      expect(policy.user).to eq(admin_user)
      expect(policy.record).to eq(record)
    end
  end

  describe '#access?' do
    it 'allows access for admin users' do
      policy = ApplicationPolicy.new(admin_user, record)
      expect(policy.access?).to be true
    end

    it 'denies access for non-admin users' do
      policy = ApplicationPolicy.new(customer_user, record)
      expect(policy.access?).to be false
    end

    it 'denies access for nil user' do
      policy = ApplicationPolicy.new(nil, record)
      expect(policy.access?).to be false
    end
  end

  describe 'permission methods' do
    let(:policy) { ApplicationPolicy.new(admin_user, record) }
    let(:customer_policy) { ApplicationPolicy.new(customer_user, record) }

    it 'allows index for admin users' do
      expect(policy.index?).to be true
    end

    it 'denies index for non-admin users' do
      expect(customer_policy.index?).to be false
    end

    it 'allows show for admin users' do
      expect(policy.show?).to be true
    end

    it 'denies show for non-admin users' do
      expect(customer_policy.show?).to be false
    end

    it 'allows create for admin users' do
      expect(policy.create?).to be true
    end

    it 'denies create for non-admin users' do
      expect(customer_policy.create?).to be false
    end

    it 'allows new for admin users' do
      expect(policy.new?).to be true
    end

    it 'denies new for non-admin users' do
      expect(customer_policy.new?).to be false
    end

    it 'allows update for admin users' do
      expect(policy.update?).to be true
    end

    it 'denies update for non-admin users' do
      expect(customer_policy.update?).to be false
    end

    it 'allows edit for admin users' do
      expect(policy.edit?).to be true
    end

    it 'denies edit for non-admin users' do
      expect(customer_policy.edit?).to be false
    end

    it 'allows destroy for admin users' do
      expect(policy.destroy?).to be true
    end

    it 'denies destroy for non-admin users' do
      expect(customer_policy.destroy?).to be false
    end
  end

  describe '#scope' do
    it 'calls Pundit.policy_scope!' do
      policy = ApplicationPolicy.new(admin_user, record)
      expect(Pundit).to receive(:policy_scope!).with(admin_user, record.class)
      policy.scope
    end
  end

  describe 'Scope class' do
    let(:scope) { double('scope') }
    let(:policy_scope) { ApplicationPolicy::Scope.new(admin_user, scope) }

    it 'initializes with user and scope' do
      expect(policy_scope.user).to eq(admin_user)
      expect(policy_scope.scope).to eq(scope)
    end

    it 'resolves to the original scope' do
      expect(policy_scope.resolve).to eq(scope)
    end
  end
end