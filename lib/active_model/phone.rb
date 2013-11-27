module ActiveModel
  module Phone
    extend ActiveSupport::Concern

    PHONY_PASSTHRU_OPTIONS = [:format, :spaces]

    included do
      include ActiveModel::Validations
    end

    module ClassMethods
      def attr_phone(attr, options={})
        ActiveModel::Phone.define_accessors(self, attr.to_sym, options)
      end
    end

    class << self

      def define_attr_phone(klass, attr, options={})
        phony_options = ActiveModel::Phone.default_phony_options.merge(options).slice(PHONY_PASSTHRU_OPTIONS)
        define_cc_accessor(klass, attr, options)
        define_format_accessor(klass, attr, phony_options)
        define_local_accessor(klass, attr)
        define_natl_accessor(klass, attr)
        define_intl_accessor(klass, attr)
        define_normalization(klass, attr)
        define_validation(klass, attr)
      end

      def define_normalization(klass, attr)

        # returns the phone field formatted as to international (country code prefixed)
        # 0) return nil if the phone field is nil
        # 1) strip all spaces and non-digit chars
        # 2) remove leading zeroes
        # 3) add country code if not already present
        klass.define_method(:"#{attr}_normalize") do
          return nil unless out = self.send(:attr)
          out = out.to_s.scan(/\d+/).join
          out = out.gsub(/^0+/,'')
          cc = self.send(:"#{attr}_cc")
          out.match(/^#{cc}/) ? out : cc + out

          # try instead
          # Phony.normalize(self.send(attr), cc: self.send(:"#{attr}_cc"))
        end

        # mutates the phone field method
        klass.define_method(:"#{attr}_normalize!") do
          self.send(:"#{attr}=", self.send(:"#{attr}_format"))
        end

        before_validation :"#{attr}_normalize!"
      end

      def define_validation(klass, attr)
        validates_numericality_of attr, only_integer: true, greater_than: 0
      end

      def define_format_accessor(klass, attr, default_options = {})
        klass.define_method(:"#{attr}_format") do |options = {}|
          options = default_options.merge(options)
          Phony.format(self.send(attr), options)
        end
      end

      def define_local_accessor(klass, attr)
        klass.define_method(:"#{attr}_natl") do
          Phony.format(self.send(attr), format: :local)
        end
      end

      def define_natl_accessor(klass, attr)
        klass.define_method(:"#{attr}_natl") do
          Phony.format(self.send(attr), format: :national)
        end
      end

      def define_intl_accessor(klass, attr)
        klass.define_method(:"#{attr}_intl") do
          Phony.format(self.send(attr), format: :international)
        end
      end

      def define_cc_accessor(klass, attr)
        klass.define_method(:"#{attr}_cc") do
          self.instance_variable_get(:"@#{attr}_cc") || options[:default_cc] || ActiveModel::Phone.default_cc
        end
      end

      def define_cc_variable(klass, attr, options)
        klass.define_method(:"#{attr}_cc=") do |value|
          self.instance_variable_set(:"@#{attr}_cc", value)
        end
      end

      cattr_writer :default_cc, :default_phony_options
      def default_cc
        @@default_cc || '1'
      end

      def default_phony_options
        @@default_phony_options || {}
      end
    end
  end
end
