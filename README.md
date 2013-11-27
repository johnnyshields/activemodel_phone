# ActiveModel::Phone
[![Build Status](https://secure.travis-ci.org/johnnyshields/activemodel_phone.png)](https://travis-ci.org/johnnyshields/activemodel_phone)
[![Code Climate](https://codeclimate.com/github/johnnyshields/activemodel_phone.png)](https://codeclimate.com/github/johnnyshields/activemodel_phone)

A lightweight, opinionated ActiveModel attribute wrapper for phone numbers, using the (Phony)[https://github.com/floere/phony] gem.


## Install

```ruby
  gem 'activemodel_phone'
```

## Usage

In your model:

```ruby
class Person
  include ActiveModel::Phone

  # assumes presence of a database field or attr_accessor :phone
  attr_phone :phone
end
```

This will do the following:

* Adds a public `{field}_format!` method which converts the field value to international, all numeric without spaces which is appropriate for DB persistence.

* Before validation, calls the `_format!` method.

* Adds `validation` logic to ensure the number is all numeric without spaces.

* Defines accessors:
   * assuming raw value is '818012345678'
   * `{field}_intl`: +81 80-1234-5678
   * `{field}_natl`: 080-1234-5678
   * `{field}_local`: 1234-5678
   * `{field}_cc`: 81
   * Refer to (Phony)[https://github.com/floere/phony] documentation for an explanation of "national" versus "international" formats

* Defines mutators `{field}_intl=`, `{field}_natl=`, and `{field}_local=` which are aliased to `{field}=`

* Defines aliased mutators `{field}_intl=`, `{field}_natl=`, and `{field}_local=` which are aliased to `{field}=`


### Country Code handling

ActiveModel::Phone converts national-formatted numbers to international. As the country code can be ambiguous, ActiveModel::Phone
provides several options for this. In reverse-order of precedence:

#### 0) Default

If none of the below options are set, the default country code will be '1' (USA)

#### 1) Set global default country code

In an application initializer:

```ruby
ActiveModel::Phone.default_cc = '81'
```

#### 2) Set per-field default country code

```ruby
class Person
  include ActiveModel::Phone

  attr_phone :phone, default_cc: '91'
end
```

#### 3) Set per-field default country code

```ruby
bob = Person.new
bob.phone_cc = '44'
bob.phone = '01 1234 56789'
bob.phone_format!            # formats phone as international, assuming country code of 44
```

### Tips for Web Form Implementation

1. If you'd like to present the user's entered value without a country code, you can show an input text field for the `{field}_natl` attribute rather than `{field}` itself

2. In combo with Tip #1, you can add `{field}_cc` a dropdown selector in front of the `{field}_natl` text field.


## Alternatives

* The (Phony Rails)[https://github.com/joost/phony_rails] gem add a Swiss-army knife set of validators and helpers. Was a bit heavy for my use case.
* Roll your own with (Phony)[https://github.com/floere/phony] itself.


## Compatibility

ActiveModel::Phone is compatible any ActiveModel-based ORM/ODM library, including:

* (ActiveRecord)[https://github.com/rails/rails/tree/master/activerecord]
* (Mongoid)[https://github.com/mongoid/mongoid]
* (ActiveAttr)[https://github.com/cgriego/active_attr]

ActiveModel::Phone is tested on the following versions:

* Ruby 1.9.3 and 2.0.0
* Rails 3


## Contributing

Fork -> Patch -> Spec -> Push -> Pull Request

Please use Ruby 1.9.3 hash syntax, as ActiveModel 3 requires Ruby >= 1.9.3


## Authors

* [Johnny Shields](https://github.com/johnnyshields)


## Copyright

Copyright (c) 2013 Johnny Shields

Licensed under the MIT License (MIT). Refer to LICENSE for details.
