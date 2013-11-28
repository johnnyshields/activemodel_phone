module ActiveModel
  module Phone
    extend ActiveSupport::Concern
    include ActiveModel::Phone::AttrPhone
    extend ActiveModel::Phone::Options
    extend ActiveModel::Phone::Definitions
    extend ActiveModel::Phone::Normalize

    included do
      include ActiveModel::Validations
    end
  end
end
