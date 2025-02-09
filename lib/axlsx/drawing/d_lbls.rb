# frozen_string_literal: true

module Axlsx
  # There are more elements in the dLbls spec that allow for
  # customizations and formatting. For now, I am just implementing the
  # basics.
  # The DLbls class manages serialization of data labels
  # showLeaderLines and leaderLines are not currently implemented
  class DLbls
    include Axlsx::Accessors
    include Axlsx::OptionsParser
    # creates a new DLbls object
    def initialize(chart_type, options = {})
      raise ArgumentError, 'chart_type must inherit from Chart' unless [Chart, LineChart].include?(chart_type.superclass)

      @chart_type = chart_type
      initialize_defaults
      parse_options options
    end

    # These attributes are all boolean so I'm doing a bit of a hand
    # waving magic show to set up the attribute accessors
    # @note
    #   not all charts support all methods!
    #   Bar3DChart and Line3DChart and ScatterChart do not support d_lbl_pos or show_leader_lines
    #
    boolean_attr_accessor :show_legend_key,
                          :show_val,
                          :show_cat_name,
                          :show_ser_name,
                          :show_percent,
                          :show_bubble_size,
                          :show_leader_lines

    # Initialize all the values to false as Excel requires them to
    # explicitly be disabled or all will show.
    def initialize_defaults
      [:show_legend_key, :show_val, :show_cat_name,
       :show_ser_name, :show_percent, :show_bubble_size,
       :show_leader_lines].each do |attr|
        send(:"#{attr}=", false)
      end
      self.label_rotation = 0
    end

    # The chart type that is using this data labels instance.
    # This affects the xml output as not all chart types support the
    # same data label attributes.
    attr_reader :chart_type

    # specifies how the degree of label rotation
    # @return [Integer]
    attr_reader :label_rotation

    # The position of the data labels in the chart
    # @see d_lbl_pos= for a list of allowed values
    # @return [Symbol]
    def d_lbl_pos
      return unless [PieChart, Pie3DChart, LineChart].include? @chart_type

      @d_lbl_pos ||= :bestFit
    end

    # @see DLbls#d_lbl_pos
    # Assigns the label position for this data labels on this chart.
    # Allowed positions are :bestFit, :b, :ctr, :inBase, :inEnd, :l,
    # :outEnd, :r and :t
    # The default is :bestFit
    # @param [Symbol] label_position the position you want to use.
    def d_lbl_pos=(label_position)
      return unless [PieChart, Pie3DChart, LineChart].include? @chart_type

      Axlsx::RestrictionValidator.validate 'DLbls#d_lbl_pos', [:bestFit, :b, :ctr, :inBase, :inEnd, :l, :outEnd, :r, :t], label_position
      @d_lbl_pos = label_position
    end

    # Specify the degree of label rotation to apply to labels
    # default 0
    def label_rotation=(v)
      Axlsx.validate_int(v)
      adjusted = v.to_i * 60000
      Axlsx.validate_angle(adjusted)
      @label_rotation = adjusted
    end

    # serializes the data labels
    # @return [String]
    def to_xml_string(str = +'')
      validate_attributes_for_chart_type
      str << '<c:dLbls>'

      str << '<c:txPr><a:bodyPr rot="' << label_rotation.to_s << '"/><a:lstStyle/><a:p><a:pPr><a:defRPr/></a:pPr><a:endParaRPr/></a:p></c:txPr>'

      instance_vals = Axlsx.instance_values_for(self)
      %w(d_lbl_pos show_legend_key show_val show_cat_name show_ser_name show_percent show_bubble_size show_leader_lines).each do |key|
        next unless instance_vals.key?(key) && !instance_vals[key].nil?

        str << "<c:#{Axlsx.camel(key, false)} val='#{instance_vals[key]}' />"
      end
      str << '</c:dLbls>'
    end

    # nills out d_lbl_pos and show_leader_lines as these attributes, while valid in the spec actually crash Excel for any chart type other than pie charts.
    def validate_attributes_for_chart_type
      return if [PieChart, Pie3DChart, LineChart].include? @chart_type

      @d_lbl_pos = nil
      @show_leader_lines = nil
    end
  end
end
