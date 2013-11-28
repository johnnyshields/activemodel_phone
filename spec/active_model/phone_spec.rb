
require 'spec_helper'

describe ActiveModel::Phone do

  describe 'module methods' do

    describe '::default_options' do

      it 'should default to empty hash' do
        subject.default_options.should eq(validate: true, before_validation: true, default_cc: '1')
      end

      it 'should persist values' do
        subject.default_options = {foo: 'bar', validate: false, default_cc: '81'}
        subject.default_options.should eq(foo: 'bar', validate: false, before_validation: true, default_cc: '81')
        subject.default_options = {validate: true, before_validation: true, default_cc: '1'}
        subject.default_options.should eq(validate: true, before_validation: true, default_cc: '1')
      end
    end
  end

  describe 'class methods' do

    describe '::attr_phone' do

      subject { ExampleMultiArgs.new }

      it 'should allow multiple attrs' do
        subject.respond_to?(:phone_natl).should
        subject.respond_to?(:fax_natl).should be_true
      end
    end
  end

  describe 'instance methods' do

    subject { ExampleSimple.new }

    describe 'validations' do

      context 'when :validation option is true' do
        pending 'should accept numerical of phone numbers'
        pending 'should reject non-numerical of phone numbers'
        pending 'should accept plausible phone numbers'
        pending 'should reject non-plausible phone numbers'
      end

      context 'when :validation option is false' do
        pending 'should accept non-numerical of phone numbers'
        pending 'should accept non-plausible phone numbers'
      end
    end

    describe 'before_validation callback' do

      context 'when framework supports before_validation callback' do

        context 'when :before_validation option is true' do
          pending 'should callback normalize! before validation'
        end

        context 'when :before_validation option is false' do
          pending 'should not callback normalize! before validation'
        end
      end

      context 'when framework does not support before_validation callback' do
        pending 'should not callback normalize! before validation'
      end
    end

    describe '#phone_normalize' do

      it 'should return nil if underlying field is not set' do
        subject.phone_normalize.should eq nil
      end

      it 'should convert the field value to all numeric without spaces' do
        subject.phone = '1 2A06 123 4a567 ABC'
        subject.phone_normalize.should eq '12061234567'
      end

      it 'should convert the field value to international' do
        subject.phone = '206 123 4567'
        subject.phone_normalize.should eq '12061234567'
      end

      it 'should strip leading zeroes' do
        subject.phone = '00206 123 4567'
        subject.phone_normalize.should eq '12061234567'
      end

      it 'should convert the field value to all numeric without spaces' do
        subject.phone = '1 2A06 123 4a567 ABC'
        subject.phone_normalize.should eq '12061234567'
      end

      context 'when a before_normalize hook is specified' do
        subject { ExampleWithHook.new }

        it 'should apply the hook at the beginning of the normalization' do
          subject.phone = '2061234'
          subject.phone_normalize.should eq '19992061234'
        end
      end

      context 'country-code behavior' do

        context 'when the _cc accessor is set' do
          before { subject.phone_cc = '81' }

          it 'should apply the default country code' do
            subject.phone = '08012345678'
            subject.phone_normalize.should eq '818012345678'
          end
        end

        context 'when a default country code is set' do
          subject { ExampleCountryCode.new }

          it 'should apply the default country code' do
            subject.phone = '08012345678'
            subject.phone_normalize.should eq '818012345678'
          end
        end
      end
    end

    describe '#phone_normalize!' do

      it 'should mutate the underlying field' do
        subject.phone = '2061234567'
        subject.phone_normalize!
        subject.phone.should eq '12061234567'
      end
    end

    describe 'format methods' do
      before { subject.phone = '81312345678' }

      describe '#phone_format' do

        it 'should accept Phony :spaces option' do
          subject.phone_format(spaces: '-').should eq '+81-3-1234-5678'
        end

        it 'should accept Phony :format option' do
          subject.phone_format(format: :national, cc: '81').should eq '03 1234 5678'
        end
      end

      describe '#phone_intl' do
        its(:phone_intl){ should eq '+81 3 1234 5678' }
      end

      describe '#phone_natl' do
        its(:phone_natl){ should eq '03 1234 5678' }
      end

      describe '#phone_local' do
        its(:phone_local){ should eq '1234 5678' }
      end
    end

    describe '#phone_cc' do

      pending 'it should get the internal instance variable'
      pending 'it should fallback to the attribute-level cc default'
      pending 'it should fallback to the ActiveModel::Phone cc default'

      context 'when #phone_cc has already been defined' do
        subject { ExampleExistingMethods.new }

        it 'should not override the existing method' do
          subject.phone_cc.should eq '55'
        end
      end
    end

    describe '#phone_cc=' do

      pending 'it should set the internal instance variable'

      context 'when #phone_cc= has already been defined' do
        subject { ExampleExistingMethods.new }

        it 'should not override the existing method' do
          ->{ subject.phone_cc='foo' }.should raise_error
        end
      end
    end

    describe 'preformatted aliases' do
      %w(intl natl local).each do |format|
        it "#{format}= should set base field" do
          subject.send("phone_#{format}=", '2061234567')
          subject.phone.should eq '2061234567'
        end
      end
    end
  end
end
