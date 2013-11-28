module ActiveModel
  module Phone
    module Options
      extend ActiveSupport::Concern

      DEFAULT_OPTIONS = {validate: true, before_validation: true, default_cc: '1'}
      PHONY_PASSTHRU_OPTIONS = [:format, :spaces]

      attr_writer :default_options

      def default_options
        DEFAULT_OPTIONS.merge(@default_options || {})
      end

      def options_with_default(options = {})
        default_options.merge(options)
      end

      def extract_phony_options(options = {})
        options.slice(PHONY_PASSTHRU_OPTIONS)
      end
    end
  end
end
