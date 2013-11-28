module ActiveModel
  module Phone
    module Normalize
      extend ActiveSupport::Concern

      # returns the phone field formatted as to international (country code prefixed)
      # 0) return nil if the phone field is nil
      # 1) call :before_normalize Proc, if given
      # 2) strip all spaces and non-digit chars
      # 3) remove leading zeroes
      # 4) add country code if not already present
      def normalize(value, cc, options = {})
        return nil unless value
        hook = options[:before_normalize]
        value = value.to_s
        value = hook.call(value) if hook && hook.is_a?(Proc)
        value = value.scan(/\d+/).join
        value = value.gsub(/^0+/,'')
        value.match(/^#{cc}/) ? value : cc + value
        # I tried Phony.normalize here, but seems to doesn't convert national to intl automatically
        # Phony.normalize(out, cc)
      end

      def normalize_attr(instance, attr, options = {})
        normalize(instance.send(attr), instance.send(:"#{attr}_cc"), options)
      end
    end
  end
end
