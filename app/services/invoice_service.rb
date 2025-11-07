# frozen_string_literal: true

require 'prawn'
require 'prawn/table'

class InvoiceService
  def self.generate_pdf(order)
    new(order).generate
  end

  def initialize(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(
      product_variant: { product: [:brand, :category] }
    )
  end

  def generate
    pdf = Prawn::Document.new(
      page_size: 'A4',
      page_layout: :portrait,
      margin: [50, 50, 50, 50]
    )

    # Header
    pdf.text 'INVOICE', size: 24, style: :bold, align: :center
    pdf.move_down 20

    # Company Info and Invoice Details
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.float do
        # Company Info (Left)
        pdf.text 'LuxeThreads', size: 16, style: :bold
        pdf.text 'Premium Fashion E-commerce', size: 10
        pdf.text 'Email: support@luxethreads.com', size: 10
        pdf.text 'Phone: +91-XXX-XXX-XXXX', size: 10
      end

      # Invoice Details (Right)
      pdf.float do
        pdf.bounding_box([pdf.bounds.width - 200, pdf.bounds.height], width: 200) do
          pdf.text "Invoice #: #{@order.order_number || @order.id}", size: 12, style: :bold, align: :right
          pdf.text "Date: #{@order.created_at.strftime('%B %d, %Y')}", size: 10, align: :right
          pdf.text "Order #: #{@order.order_number || @order.id}", size: 10, align: :right
          pdf.text "Status: #{@order.status.upcase}", size: 10, align: :right
        end
      end
    end

    pdf.move_down 30

    # Billing and Shipping Address
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.float do
        # Billing Address
        pdf.text 'Bill To:', size: 12, style: :bold
        pdf.text @order.billing_address.full_name, size: 10
        pdf.text @order.billing_address.line1, size: 10
        pdf.text "#{@order.billing_address.city}, #{@order.billing_address.state}", size: 10
        pdf.text @order.billing_address.postal_code, size: 10
        pdf.text @order.billing_address.country, size: 10
      end

      pdf.float do
        # Shipping Address
        pdf.bounding_box([pdf.bounds.width / 2, pdf.bounds.height], width: pdf.bounds.width / 2) do
          pdf.text 'Ship To:', size: 12, style: :bold
          pdf.text @order.shipping_address.full_name, size: 10
          pdf.text @order.shipping_address.line1, size: 10
          pdf.text "#{@order.shipping_address.city}, #{@order.shipping_address.state}", size: 10
          pdf.text @order.shipping_address.postal_code, size: 10
          pdf.text @order.shipping_address.country, size: 10
        end
      end
    end

    pdf.move_down 30

    # Order Items Table
    items_data = [['Item', 'SKU', 'Quantity', 'Price', 'Total']]
    
    @order_items.each do |item|
      variant = item.product_variant
      product = variant.product
      item_name = "#{product.name}"
      item_name += " - #{variant.sku}" if variant.sku.present?
      
      items_data << [
        item_name,
        variant.sku || 'N/A',
        item.quantity.to_s,
        "₹#{item.price_at_purchase.to_f.round(2)}",
        "₹#{(item.price_at_purchase * item.quantity).to_f.round(2)}"
      ]
    end

    pdf.table(items_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'E0E0E0'
      columns(0).width = 200
      columns(1).width = 100
      columns(2).width = 80
      columns(3).width = 100
      columns(4).width = 100
      columns(3..4).align = :right
      columns(2).align = :center
    end

    pdf.move_down 20

    # Totals
    subtotal = @order.total_amount + (@order.coupon_discount || 0)
    tax = (subtotal * 0.18).round(2) # 18% GST
    discount = @order.coupon_discount || 0
    total = @order.total_amount + tax

    totals_data = [
      ['Subtotal:', "₹#{subtotal.to_f.round(2)}"],
      ['Discount:', discount > 0 ? "-₹#{discount.to_f.round(2)}" : "₹0.00"],
      ['Tax (18%):', "₹#{tax.to_f.round(2)}"],
      ['Total:', "₹#{total.to_f.round(2)}"]
    ]

    pdf.bounding_box([pdf.bounds.width - 200, pdf.cursor], width: 200) do
      pdf.table(totals_data, width: 200) do
        columns(0).font_style = :bold
        columns(1).align = :right
        row(-1).font_style = :bold
        row(-1).font_size = 14
      end
    end

    pdf.move_down 30

    # Payment Information
    if @order.payments.any?
      payment = @order.payments.first
      pdf.text 'Payment Information:', size: 12, style: :bold
      pdf.text "Payment Method: #{payment.payment_method || 'N/A'}", size: 10
      pdf.text "Payment Status: #{@order.payment_status}", size: 10
      pdf.text "Payment Date: #{payment.created_at.strftime('%B %d, %Y')}", size: 10 if payment.created_at
      pdf.move_down 10
    end

    # Footer
    pdf.move_down 20
    pdf.text 'Thank you for your business!', size: 12, style: :italic, align: :center
    pdf.move_down 10
    pdf.text 'For any queries, please contact support@luxethreads.com', size: 9, align: :center, color: '666666'

    pdf.render
  end
end

