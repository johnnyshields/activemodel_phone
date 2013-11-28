module ActiveModel
  module Phone
    module AttrPhone
      extend ActiveSupport::Concern

      module ClassMethods

        def attr_phone(*args)
          options = args.extract_options!
          args.each {|attr| ActiveModel::Phone.define_attr_phone(self, attr.to_sym, options) }
        end
      end
    end
  end
end
