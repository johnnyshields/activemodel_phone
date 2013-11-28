module ActiveModel
  module Phone
    extend ActiveSupport::Concern

    DEFAULT_OPTIONS = {validate: true, before_validation: true, default_cc: '1'}
    PHONY_PASSTHRU_OPTIONS = [:format, :spaces]
    PREFORMATTED_METHODS = {intl: :international, natl: :national, local: :local}

    class << self

      attr_writer :default_options

      def default_options
        DEFAULT_OPTIONS.merge(@default_options || {})
      end
    end

    included do
      include ActiveModel::Validations
    end

    module ClassMethods

      def attr_phone(*args)
        options = args.extract_options!
        args.each {|attr| ActiveModel::Phone.define_attr_phone(self, attr.to_sym, options) }
      end
    end

    class << self

      def define_attr_phone(klass, attr, options={})
        options = ActiveModel::Phone.default_options.merge(options)
        phony_options = options.slice(PHONY_PASSTHRU_OPTIONS)
        define_cc_accessor(klass, attr, options)
        define_format_accessor(klass, attr, phony_options)
        define_preformatted_accessors(klass, attr)
        define_preformatted_aliases(klass, attr)
        define_normalization(klass, attr, options)
        define_normalization_callback(klass, attr, options)
        define_validation(klass, attr, options)
      end

      def define_normalization(klass, attr, options = {})
        klass.class_eval do

          # returns the phone field formatted as to international (country code prefixed)
          # 0) return nil if the phone field is nil
          # 1) call :before_normalize Proc, if given
          # 2) strip all spaces and non-digit chars
          # 3) remove leading zeroes
          # 4) add country code if not already present
          self.send(:define_method, :"#{attr}_normalize") do
            return nil unless out = self.send(attr)
            out = out.to_s
            hook = options[:before_normalize]
            out = hook.call(out) if hook && hook.is_a?(Proc)
            out = out.scan(/\d+/).join
            out = out.gsub(/^0+/,'')
            cc = self.send(:"#{attr}_cc")
            out.match(/^#{cc}/) ? out : cc + out

            # I tried Phony.normalize here, but seems to doesn't convert national to intl automatically
            # Phony.normalize(out, cc: self.send(:"#{attr}_cc"))
          end

          # mutates the phone field method
          self.send(:define_method, :"#{attr}_normalize!") do
            self.send(:"#{attr}=", self.send(:"#{attr}_normalize"))
          end
        end
      end

      def define_normalization_callback(klass, attr, options = {})
        if options[:before_validation]
          klass.class_eval do
            before_validation :"#{attr}_normalize!" if self.respond_to?(:before_validation)
          end
        end
      end

      def define_validation(klass, attr, options = {})
        if options[:validate]
          klass.class_eval do
            validates_numericality_of attr, only_integer: true, greater_than: 0
          end
        end
      end

      def define_format_accessor(klass, attr, default_options = {})
        klass.class_eval do
          self.send(:define_method, :"#{attr}_format") do |options = {}|
            options = default_options.merge(options)
            ::Phony.format(self.send(attr), options)
          end
        end
      end

      def define_preformatted_accessors(klass, attr)
        PREFORMATTED_METHODS.each do |scope, format|
          klass.class_eval do
            self.send(:define_method, :"#{attr}_#{scope}") do
              self.send(:"#{attr}_format", format: format)
            end
          end
        end
      end

      # Setting any of the preformatted methods sets the base field. Useful for web forms.
      def define_preformatted_aliases(klass, attr)
        PREFORMATTED_METHODS.keys.each do |scope|
          klass.class_eval do
            self.send(:alias_method, :"#{attr}_#{scope}=", :"#{attr}=")
          end
        end
      end

      def define_cc_accessor(klass, attr, options)
        klass.class_eval do
          unless self.method_defined?(:"#{attr}_cc")
            self.send(:define_method, :"#{attr}_cc") do
              self.instance_variable_get(:"@#{attr}_cc") || options[:default_cc]
            end
          end
          unless self.method_defined?(:"#{attr}_cc=")
            self.send(:attr_writer, :"#{attr}_cc")
          end
        end
      end
    end
  end
end
