module Axlsx
  # This module allows us to define a list of symbols defining which
  # attributes will be serialized for a class.
  module SerializedAttributes
    # Extend with class methods
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # class methods applied to all includers
    module ClassMethods
      # This is the method to be used in inheriting classes to specify
      # which of the instance values are serializable
      def serializable_attributes(*symbols)
        @xml_attributes = symbols
        @camelized_xml_attributes = nil
      end

      # a reader for those attributes
      attr_reader :xml_attributes

      def camelized_xml_attributes
        @camelized_xml_attributes ||= @xml_attributes.map { |attr| Axlsx.camel(attr, false) }
      end

      # This helper registers the attributes that will be formatted as elements.
      def serializable_element_attributes(*symbols)
        @xml_element_attributes = symbols
      end

      # attr reader for element attributes
      attr_reader :xml_element_attributes
    end

    # creates a XML tag with serialized attributes
    # @see SerializedAttributes#serialized_attributes
    def serialized_tag(tagname, str, additional_attributes = {}, &block)
      str << "<#{tagname} "
      serialized_attributes(str, additional_attributes)
      if block_given?
        str << '>'
        yield
        str << "</#{tagname}>"
      else
        str << '/>'
      end
    end

    # serializes the instance values of the defining object based on the
    # list of serializable attributes.
    # @param [String] str The string instance to append this
    # serialization to.
    # @param [Hash] additional_attributes An option key value hash for
    # defining values that are not serializable attributes list.
    def serialized_attributes(str = +'', additional_attributes = {}, camelize_value = true)
      camelized_xml_attributes = self.class.camelized_xml_attributes

      self.class.xml_attributes.each_with_index do |attr, index|
        next if additional_attributes.key?(attr)

        value = instance_variable_get(:"@#{attr}")
        next if value.nil?

        value = Axlsx.booleanize(value)
        value = Axlsx.camel(value, false) if camelize_value
        str << camelized_xml_attributes[index] << '="' << value.to_s << '" '
      end

      additional_attributes.each do |attr, value|
        next if value.nil?

        value = Axlsx.booleanize(value)
        value = Axlsx.camel(value, false) if camelize_value
        str << Axlsx.camel(attr, false) << '="' << value.to_s << '" '
      end

      str
    end

    # serialized instance values at text nodes on a camelized element of the
    # attribute name. You may pass in a block for evaluation against non nil
    # values. We use an array for element attributes becuase misordering will
    # break the xml and 1.8.7 does not support ordered hashes.
    # @param [String] str The string instance to which serialized data is appended
    # @param [Array] additional_attributes An array of additional attribute names.
    # @return [String] The serialized output.
    def serialized_element_attributes(str = '', additional_attributes = [], &block)
      attrs = self.class.xml_element_attributes + additional_attributes
      values = Axlsx.instance_values_for(self)
      attrs.each do |attribute_name|
        value = values[attribute_name.to_s]
        next if value.nil?

        value = yield value if block_given?
        element_name = Axlsx.camel(attribute_name, false)
        str << "<#{element_name}>#{value}</#{element_name}>"
      end
      str
    end
  end
end
