module ActiveModel
  module Phone
    module Definitions
      extend ActiveSupport::Concern

      PREFORMATTED_METHODS = {intl: :international, natl: :national, local: :local}

      def define_attr_phone(klass, attr, options={})
        options = options_with_default(options)
        phony_options = extract_phony_options(options)
        define_cc_getter(klass, attr, options)
        define_cc_setter(klass, attr)
        define_formatted_getter(klass, attr, phony_options)
        define_preformatted_getters(klass, attr)
        define_preformatted_aliases(klass, attr)
        define_normalization_getter(klass, attr, options)
        define_normalization_mutator(klass, attr, options)
        define_normalization_callback(klass, attr, options)
        define_validation(klass, attr, options)
      end

      def define_normalization_getter(klass, attr, options = {})
        klass.class_eval do
          self.send(:define_method, :"#{attr}_normalize") do
            ActiveModel::Phone.normalize_attr(self, attr, options)
          end
        end
      end

      def define_normalization_mutator(klass, attr, options = {})
        klass.class_eval do
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

      def define_formatted_getter(klass, attr, default_options = {})
        klass.class_eval do
          self.send(:define_method, :"#{attr}_format") do |options = {}|
            options = default_options.merge(options)
            ::Phony.format(self.send(attr), options)
          end
        end
      end

      def define_preformatted_getters(klass, attr)
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

      def define_cc_getter(klass, attr, options)
        klass.class_eval do
          unless self.method_defined?(:"#{attr}_cc")
            self.send(:define_method, :"#{attr}_cc") do
              self.instance_variable_get(:"@#{attr}_cc") || options[:default_cc]
            end
          end
        end
      end

      def define_cc_setter(klass, attr)
        klass.class_eval do
          unless self.method_defined?(:"#{attr}_cc=")
            self.send(:attr_writer, :"#{attr}_cc")
          end
        end
      end
    end
  end
end
