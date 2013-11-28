
class ExampleSimple
  include ActiveModel::Phone
  attr_accessor :phone
  attr_phone :phone
end

class ExampleMultiArgs
  include ActiveModel::Phone
  attr_accessor :phone, :fax
  attr_phone :phone, :fax
end

class ExampleCountryCode
  include ActiveModel::Phone
  attr_accessor :phone
  attr_phone :phone, default_cc: '81'
end

class ExampleFormatted
  include ActiveModel::Phone
  attr_accessor :phone
  attr_phone :phone, spaces: '-'
end

class ExampleWithHook
  include ActiveModel::Phone
  attr_accessor :phone
  attr_phone :phone, before_normalize: ->(num){ '999'+num }
end

class ExampleExistingMethods
  include ActiveModel::Phone
  attr_accessor :phone

  def phone_cc
    '55'
  end

  def phone_cc=(value)
    raise 'do nothing'
  end

  attr_phone :phone
end