# frozen_string_literal: true

require 'axlsx/workbook/worksheet/auto_filter/filter_column.rb'
require 'axlsx/workbook/worksheet/auto_filter/filters.rb'
require 'axlsx/workbook/worksheet/auto_filter/sort_state.rb'

module Axlsx
  # This class represents an auto filter range in a worksheet
  class AutoFilter
    # creates a new Autofilter object
    # @param [Worksheet] worksheet
    def initialize(worksheet)
      raise ArgumentError, 'you must provide a worksheet' unless worksheet.is_a?(Worksheet)

      @worksheet = worksheet
    end

    attr_reader :worksheet

    # The range the autofilter should be applied to.
    # This should be a string like 'A1:B8'
    # @return [String]
    attr_accessor :range

    # the formula for the defined name required for this auto filter
    # This prepends the worksheet name to the absolute cell reference
    # e.g. A1:B2 -> 'Sheet1'!$A$1:$B$2
    # @return [String]
    def defined_name
      return unless range

      Axlsx.cell_range(range.split(':').collect { |name| worksheet.name_to_cell(name) })
    end

    # A collection of filterColumns for this auto_filter
    # @return [SimpleTypedList]
    def columns
      @columns ||= SimpleTypedList.new FilterColumn
    end

    # Adds a filter column. This is the recommended way to create and manage filter columns for your autofilter.
    # In addition to the require id and type parameters, options will be passed to the filter column during instantiation.
    # @param [String] col_id Zero-based index indicating the AutoFilter column to which this filter information applies.
    # @param [Symbol] filter_type A symbol representing one of the supported filter types.
    # @param [Hash] options a hash of options to pass into the generated filter
    # @return [FilterColumn]
    def add_column(col_id, filter_type, options = {})
      columns << FilterColumn.new(col_id, filter_type, options)
      columns.last
    end

    # Performs the sorting of the rows based on the sort_state conditions. Then it actually performs
    # the filtering of rows who's cells do not match the filter.
    def apply
      first_cell, last_cell = range.split(':')
      start_point = Axlsx.name_to_indices(first_cell)
      end_point = Axlsx.name_to_indices(last_cell)
      # The +1 is so we skip the header row with the filter drop downs
      rows = worksheet.rows[(start_point.last + 1)..end_point.last] || []

      # the sorting of the rows if sort_conditions are available.
      if sort_state.sort_conditions.to_a != []
        sort_conditions = sort_state.sort_conditions.to_a

        sorted_rows = rows.sort do |row1, row2|
          comparison = 0

          sort_conditions.each do |condition|
            cell_value_row1 = row1.cells[condition.col_id].value
            cell_value_row2 = row2.cells[condition.col_id].value

            if condition.custom_order != []
              order = condition.custom_order
              comparison = order.index(cell_value_row1) <=> order.index(cell_value_row2)
            else
              comparison = cell_value_row1 <=> cell_value_row2
            end

            comparison = -comparison if condition.descending

            break unless comparison.zero?
          end

          comparison
        end
        insert_index = start_point.last + 1

        sorted_rows.each do |row|
          # Insert the row at the specified index
          worksheet.rows[insert_index] = row
          insert_index += 1
        end
      end

      column_offset = start_point.first
      columns.each do |column|
        rows.each do |row|
          next if row.hidden

          column.apply(row, column_offset)
        end
      end
    end

    def sort_state
      @sort_state ||= SortState.new self
    end

    # serialize the object
    # @return [String]
    def to_xml_string(str = +'')
      return unless range

      str << "<autoFilter ref='#{range}'>"
      columns.each { |filter_column| filter_column.to_xml_string(str) }
      @sort_state.to_xml_string(str)
      str << "</autoFilter>"
    end
  end
end
