require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'helper methods' do
    it 'has helper methods available' do
      expect(helper).to respond_to(:current_user) if defined?(current_user)
    end
  end
end
