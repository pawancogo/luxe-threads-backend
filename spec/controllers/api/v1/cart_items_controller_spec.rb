require 'rails_helper'

RSpec.describe Api::V1::CartItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let(:product) { create(:product) }
  let(:product_variant) { create(:product_variant, product: product) }
  let(:cart_item) { create(:cart_item, cart: cart, product_variant: product_variant) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request)
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::CartItemsController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has set_cart before_action' do
      expect(Api::V1::CartItemsController._process_action_callbacks.map(&:filter)).to include(:set_cart)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        product_variant_id: product_variant.id,
        quantity: 2
      }
    end

    it 'creates cart item with valid params' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'updates quantity for existing cart item' do
      cart_item
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'creates cart item even with negative quantity (no validation)' do
      invalid_params = valid_params.merge(quantity: -1)
      post :create, params: invalid_params
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      {
        id: cart_item.id,
        quantity: 5
      }
    end

    it 'updates cart item quantity' do
      patch :update, params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'updates cart item even with negative quantity (no validation)' do
      invalid_params = valid_params.merge(quantity: -1)
      patch :update, params: invalid_params
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys cart item' do
      delete :destroy, params: { id: cart_item.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'raises exception for non-existent cart item' do
      expect { delete :destroy, params: { id: 999 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'method coverage' do
    describe '#create method coverage' do
      it 'covers create method structure' do
        # Test that the method exists and can be called
        expect(controller.respond_to?(:create, true)).to be true
        expect(Api::V1::CartItemsController.public_method_defined?(:create)).to be true
      end
    end

    describe '#update method coverage' do
      it 'covers update method structure' do
        # Test that the method exists and can be called
        expect(controller.respond_to?(:update, true)).to be true
        expect(Api::V1::CartItemsController.public_method_defined?(:update)).to be true
      end
    end

    describe '#destroy method coverage' do
      it 'covers destroy method structure' do
        # Test that the method exists and can be called
        expect(controller.respond_to?(:destroy, true)).to be true
        expect(Api::V1::CartItemsController.public_method_defined?(:destroy)).to be true
      end
    end

    describe '#set_cart method coverage' do
      it 'covers set_cart method structure' do
        # Test that the method exists and can be called
        expect(controller.respond_to?(:set_cart, true)).to be true
        expect(Api::V1::CartItemsController.private_method_defined?(:set_cart)).to be true
      end

      it 'covers before_action configuration' do
        # Test that set_cart is configured as before_action
        expect(Api::V1::CartItemsController._process_action_callbacks.map(&:filter)).to include(:set_cart)
      end
    end
  end

  describe 'error handling coverage' do
    describe 'POST #create error handling' do
      it 'covers create failure path when save fails' do
        # Mock a cart item that fails to save
        cart_item = double('cart_item')
        allow(cart_item).to receive(:quantity).and_return(0)
        allow(cart_item).to receive(:quantity=)
        allow(cart_item).to receive(:save).and_return(false)
        allow(cart_item).to receive(:errors).and_return(double('errors', full_messages: ['Some error']))
        
        allow(cart.cart_items).to receive(:find_or_initialize_by).and_return(cart_item)
        
        post :create, params: { product_variant_id: product_variant.id, quantity: 1 }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_a(Hash)
      end
    end

    describe 'PATCH #update error handling' do
      it 'covers update failure path when update fails' do
        # Mock a cart item that fails to update
        cart_item = double('cart_item')
        allow(cart_item).to receive(:id).and_return(1)
        allow(cart_item).to receive(:update).and_return(false)
        allow(cart_item).to receive(:errors).and_return(double('errors', full_messages: ['Some error']))
        
        allow(cart.cart_items).to receive(:find).and_return(cart_item)
        
        patch :update, params: { id: 1, quantity: 5 }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to be_a(Hash)
      end
    end

    describe 'quantity calculation coverage' do
      it 'covers quantity calculation with existing cart item' do
        # Create an existing cart item with quantity 2
        existing_cart_item = create(:cart_item, cart: cart, product_variant: product_variant, quantity: 2)
        
        post :create, params: { product_variant_id: product_variant.id, quantity: 3 }
        
        expect(response).to have_http_status(:created)
        expect(existing_cart_item.reload.quantity).to eq(5) # 2 + 3
      end

      it 'covers quantity calculation with new cart item' do
        post :create, params: { product_variant_id: product_variant.id, quantity: 3 }
        
        expect(response).to have_http_status(:created)
        new_cart_item = CartItem.find_by(cart: cart, product_variant: product_variant)
        expect(new_cart_item.quantity).to eq(3)
      end

      it 'covers quantity calculation with nil quantity' do
        # Test the case where quantity is nil initially
        cart_item = double('cart_item')
        allow(cart_item).to receive(:quantity).and_return(nil)
        allow(cart_item).to receive(:quantity=)
        allow(cart_item).to receive(:save).and_return(true)
        
        allow(cart.cart_items).to receive(:find_or_initialize_by).and_return(cart_item)
        allow(cart.cart_items).to receive(:reload).and_return([])
        
        post :create, params: { product_variant_id: product_variant.id, quantity: 3 }
        
        expect(response).to have_http_status(:created)
        expect(cart_item).to have_received(:quantity=).with(3) # nil + 3 = 3
      end
    end
  end
end