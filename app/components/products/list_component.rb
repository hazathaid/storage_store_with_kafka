module Products
  class ListComponent < ViewComponent::Base
    def initialize(products:)
      @products = products
    end
  end
end
