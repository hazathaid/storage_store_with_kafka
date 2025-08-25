module Shared
  class ActionLinksComponent < ViewComponent::Base
    def initialize(record:)
      @record = record
    end

    def edit_path
      helpers.polymorphic_path([ :edit, @record ])
    end

    def delete_path
      helpers.polymorphic_path(@record)
    end
  end
end
