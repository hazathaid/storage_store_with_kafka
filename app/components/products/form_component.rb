module Products
  class FormComponent < ViewComponent::Base
    def initialize(product:)
      @product = product
    end
  end
end
