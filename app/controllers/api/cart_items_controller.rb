module Api
  class CartItemsController < ApplicationController
    before_action :set_cart
    before_action :set_cart_item, only: [:update, :destroy]

    # POST /api/cart/items
    def create
      product = Product.find(params[:product_id])

      # Cerca se il prodotto è già nel carrello
      cart_item = @cart.cart_items.find_by(item_id: product.id)

      if cart_item
        # Incrementa quantità
        cart_item.quantity += params[:quantity].to_i
        cart_item.save!
      else
        # Crea nuovo item
        cart_item = @cart.cart_items.create!(
          item_id: product.id,
          quantity: params[:quantity] || 1,
          unit_price: product.price
        )
      end

      render json: @cart.as_json, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Product not found' }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # PATCH /api/cart/items/:id
    def update
      @cart_item.update!(quantity: params[:quantity])
      render json: @cart.as_json
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    # DELETE /api/cart/items/:id
    def destroy
      @cart_item.destroy!
      render json: @cart.as_json
    end

    private

    def set_cart
      @cart = current_user.current_cart
    end

    def set_cart_item
      @cart_item = @cart.cart_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Cart item not found' }, status: :not_found
    end
  end
end
