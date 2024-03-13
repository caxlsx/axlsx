# frozen_string_literal: true

module Axlsx
  # This module defines some of the more common validating attribute
  # accessors that we use in Axlsx
  #
  # When this module is included in your class you can simply call
  #
  # string_attr_access :foo
  #
  # To generate a new, validating set of accessors for foo.
  module Accessors
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # Defines the class level xxx_attr_accessor methods
    module ClassMethods
      # Creates one or more string validated attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class.
      def string_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_string) }
      end

      # Creates one or more usigned integer attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class
      def unsigned_int_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_unsigned_int) }
      end

      # Creates one or more usigned numeric attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class
      def unsigned_numeric_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_unsigned_numeric) }
      end

      # Creates one or more integer attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class
      def int_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_int) }
      end

      # Creates one or more float (double?) attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class
      def float_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_float) }
      end

      # Creates on or more boolean validated attr_accessors
      # @param [Array] symbols An array of symbols representing the
      # names of the attributes you will add to your class.
      def boolean_attr_accessor(*symbols)
        symbols.each { |symbol| validated_attr_accessor(symbol, :validate_boolean) }
      end

      # Creates the reader and writer access methods
      # @param [Symbol] symbol The names of the attributes to create
      # @param [Symbol|String] validator The axlsx validation method to use when
      # validating assignation.
      # @see lib/axlsx/util/validators.rb
      def validated_attr_accessor(symbol, validator)
        attr_reader symbol

        module_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{symbol}=(value)      # def name=(value)
            Axlsx.#{validator} value #   Axlsx.validate_string value
            @#{symbol} = value       #   @name = value
          end                        # end
        RUBY_EVAL
      end
    end
  end
end
