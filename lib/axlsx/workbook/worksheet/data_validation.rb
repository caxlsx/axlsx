# frozen_string_literal: true

module Axlsx
  # Data validation allows the validation of cell data
  #
  # @note The recommended way to manage data validations is via Worksheet#add_data_validation
  # @see Worksheet#add_data_validation
  class DataValidation
    include Axlsx::Accessors
    include Axlsx::OptionsParser

    # Creates a new {DataValidation} object
    # @option options [String] formula1
    # @option options [String] formula2
    # @option options [Boolean] allowBlank - A boolean value indicating whether the data validation allows the use of empty or blank entries.
    # @option options [String] error - Message text of error alert.
    # @option options [Symbol] errorStyle - The style of error alert used for this data validation.
    # @option options [String] errorTitle - Title bar text of error alert.
    # @option options [Symbol] operator - The relational operator used with this data validation.
    # @option options [String] prompt - Message text of input prompt.
    # @option options [String] promptTitle - Title bar text of input prompt.
    # @option options [Boolean] showDropDown - A boolean value indicating whether to display a dropdown combo box for a list type data validation. Be careful: It has an inverted logic, false shows the dropdown list! You should use hideDropDown instead.
    # @option options [Boolean] hideDropDown - A boolean value indicating whether to hide the dropdown combo box for a list type data validation. Defaults to `false` (meaning the dropdown is visible by default).
    # @option options [Boolean] showErrorMessage - A boolean value indicating whether to display the error alert message when an invalid value has been entered, according to the criteria specified.
    # @option options [Boolean] showInputMessage - A boolean value indicating whether to display the input prompt message.
    # @option options [String] sqref - Range over which data validation is applied, in "A1:B2" format.
    # @option options [Symbol] type - The type of data validation.
    def initialize(options = {})
      # defaults
      @formula1 = @formula2 = @error = @errorTitle = @operator = @prompt = @promptTitle = @sqref = nil
      @allowBlank = @showErrorMessage = true
      @showDropDown = @showInputMessage = false
      @type = :none
      @errorStyle = :stop
      parse_options options
    end

    # instance values that must be serialized as their own elements - e.g. not attributes.
    CHILD_ELEMENTS = [:formula1, :formula2].freeze

    # Formula1
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :formula1

    # Formula2
    # Available for type whole, decimal, date, time, textLength
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :formula2

    # Allow Blank
    # A boolean value indicating whether the data validation allows the use of empty or blank
    # entries. 1 means empty entries are OK and do not violate the validation constraints.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [Boolean]
    # default true
    # @!attribute
    boolean_attr_accessor :allowBlank

    # Error Message
    # Message text of error alert.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :error

    # Error Style (ST_DataValidationErrorStyle)
    # The style of error alert used for this data validation.
    # Options are:
    #  * information: This data validation error style uses an information icon in the error alert.
    #  * stop: This data validation error style uses a stop icon in the error alert.
    #  * warning: This data validation error style uses a warning icon in the error alert.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [Symbol]
    # default :stop
    # @!attribute
    validated_attr_accessor :errorStyle, :validate_data_validation_error_style

    # Error Title
    # Title bar text of error alert.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :errorTitle

    # Operator (ST_DataValidationOperator)
    # The relational operator used with this data validation.
    # Options are:
    #  * between: Data validation which checks if a value is between two other values.
    #  * equal: Data validation which checks if a value is equal to a specified value.
    #  * greater_than: Data validation which checks if a value is greater than a specified value.
    #  * greater_than_or_equal: Data validation which checks if a value is greater than or equal to a specified value.
    #  * less_than: Data validation which checks if a value is less than a specified value.
    #  * less_than_or_equal: Data validation which checks if a value is less than or equal to a specified value.
    #  * not_between: Data validation which checks if a value is not between two other values.
    #  * not_equal: Data validation which checks if a value is not equal to a specified value.
    # Available for type whole, decimal, date, time, textLength
    # @see type
    # @return [Symbol]
    # default nil
    # @!attribute
    validated_attr_accessor :operator, :validate_data_validation_operator

    # Input prompt
    # Message text of input prompt.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :prompt

    # Prompt title
    # Title bar text of input prompt.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :promptTitle

    # Show drop down
    # A boolean value indicating whether to display a dropdown combo box for a list type data
    # validation. Be careful: It has an inverted logic, false shows the dropdown list!
    # Available for type list
    # @see type
    # @return [Boolean]
    # default false
    attr_reader :showDropDown

    # Hide drop down
    # A boolean value indicating whether to hide a dropdown combo box for a list type data
    # validation. Defaults to `false` (meaning the dropdown is visible by default).
    # Available for type list
    # @see type
    # @return [Boolean]
    # default false
    alias :hideDropDown :showDropDown

    # Show error message
    # A boolean value indicating whether to display the error alert message when an invalid
    # value has been entered, according to the criteria specified.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [Boolean]
    # default false
    # @!attribute
    boolean_attr_accessor :showErrorMessage

    # Show input message
    # A boolean value indicating whether to display the input prompt message.
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [Boolean]
    # default false
    # @!attribute
    boolean_attr_accessor :showInputMessage

    # Range over which data validation is applied, in "A1:B2" format
    # Available for type whole, decimal, date, time, textLength, list, custom
    # @see type
    # @return [String]
    # default nil
    # @!attribute
    string_attr_accessor :sqref

    # The type (ST_DataValidationType) of data validation.
    # Options are:
    #  * custom: Data validation which uses a custom formula to check the cell value.
    #  * date: Data validation which checks for date values satisfying the given condition.
    #  * decimal: Data validation which checks for decimal values satisfying the given condition.
    #  * list: Data validation which checks for a value matching one of list of values.
    #  * none: No data validation.
    #  * textLength: Data validation which checks for text values, whose length satisfies the given condition.
    #  * time: Data validation which checks for time values satisfying the given condition.
    #  * whole: Data validation which checks for whole number values satisfying the given condition.
    # @return [Symbol]
    # default none
    # @!attribute
    validated_attr_accessor :type, :validate_data_validation_type

    # @see showDropDown
    def showDropDown=(v)
      warn 'The `showDropDown` has an inverted logic, false shows the dropdown list! You should use `hideDropDown` instead.'
      Axlsx.validate_boolean(v)
      @showDropDown = v
    end

    # @see hideDropDown
    def hideDropDown=(v)
      Axlsx.validate_boolean(v)
      # It's just an alias for the showDropDown attribute, hideDropDown should set the value of the original showDropDown.
      @showDropDown = v
    end

    # Serializes the data validation
    # @param [String] str
    # @return [String]
    def to_xml_string(str = +'')
      valid_attributes = get_valid_attributes
      h = Axlsx.instance_values_for(self).select { |key, _| valid_attributes.include?(key.to_sym) && !CHILD_ELEMENTS.include?(key.to_sym) }

      str << '<dataValidation '
      h.each_with_index do |key_value, index|
        str << ' ' unless index.zero?
        str << key_value.first << '="' << Axlsx.booleanize(key_value.last).to_s << '"'
      end
      str << '>'
      str << '<formula1>' << formula1 << '</formula1>' if formula1 && valid_attributes.include?(:formula1)
      str << '<formula2>' << formula2 << '</formula2>' if formula2 && valid_attributes.include?(:formula2)
      str << '</dataValidation>'
    end

    private

    def get_valid_attributes
      attributes = [:allowBlank, :error, :errorStyle, :errorTitle, :prompt, :promptTitle, :showErrorMessage, :showInputMessage, :sqref, :type]

      if [:whole, :decimal, :data, :time, :date, :textLength].include?(@type)
        attributes << :operator << :formula1
        attributes << :formula2 if [:between, :notBetween].include?(@operator)
      elsif @type == :list
        attributes << :showDropDown << :formula1
      elsif @type == :custom
        attributes << :formula1
      end

      attributes
    end
  end
end
