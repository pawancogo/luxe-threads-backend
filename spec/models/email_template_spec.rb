require 'rails_helper'

RSpec.describe EmailTemplate, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:template_type) }
    it { should validate_presence_of(:subject) }
    it { should validate_uniqueness_of(:template_type) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active templates' do
        active = create(:email_template, is_active: true)
        inactive = create(:email_template, is_active: false)
        expect(EmailTemplate.active).to include(active)
        expect(EmailTemplate.active).not_to include(inactive)
      end
    end
  end

  describe 'class methods' do
    describe '.render' do
      it 'renders template with variables' do
        template = create(:email_template, 
                         template_type: 'welcome',
                         subject: 'Welcome {{name}}',
                         body_html: 'Hello {{name}}')
        
        result = EmailTemplate.render('welcome', { name: 'John' })
        expect(result[:subject]).to eq('Welcome John')
        expect(result[:body_html]).to eq('Hello John')
      end
    end
  end

  describe 'instance methods' do
    let(:template) { create(:email_template, subject: 'Hello {{name}}') }

    describe '#interpolate' do
      it 'interpolates variables' do
        result = template.interpolate(template.subject, { name: 'John' })
        expect(result).to eq('Hello John')
      end
    end
  end
end





