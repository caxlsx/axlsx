# frozen_string_literal: true

require 'tc_helper'
require 'support/capture_warnings'

class TestPackage < Test::Unit::TestCase
  include CaptureWarnings

  def setup
    @package = Axlsx::Package.new
    ws = @package.workbook.add_worksheet
    ws.add_row ['Can', 'we', 'build it?']
    ws.add_row ['Yes!', 'We', 'can!']
    @rt = Axlsx::RichText.new
    @rt.add_run "run 1", b: true, i: false
    ws.add_row [@rt]

    ws.rows.last.add_cell('b', type: :text)

    ws.outline_level_rows 0, 1
    ws.outline_level_columns 0, 1
    ws.add_hyperlink ref: ws.rows.first.cells.last, location: 'https://github.com/randym'
    ws.workbook.add_defined_name("#{ws.name}!A1:C2", name: '_xlnm.Print_Titles', hidden: true)
    ws.workbook.add_view active_tab: 1, first_sheet: 0
    ws.protect_range('A1:C1')
    ws.protect_range(ws.rows.last.cells)
    ws.add_comment author: 'alice', text: 'Hi Bob', ref: 'A12'
    ws.add_comment author: 'bob', text: 'Hi Alice', ref: 'F19'
    ws.sheet_view do |vs|
      vs.pane do |p|
        p.active_pane = :top_right
        p.state = :split
        p.x_split = 11_080
        p.y_split = 5000
        p.top_left_cell = 'C44'
      end

      vs.add_selection(:top_left, { active_cell: 'A2', sqref: 'A2' })
      vs.add_selection(:top_right, { active_cell: 'I10', sqref: 'I10' })
      vs.add_selection(:bottom_left, { active_cell: 'E55', sqref: 'E55' })
      vs.add_selection(:bottom_right, { active_cell: 'I57', sqref: 'I57' })
    end

    ws.add_chart(Axlsx::Pie3DChart, title: "これは？", start_at: [0, 3]) do |chart|
      chart.add_series data: [1, 2, 3], labels: ["a", "b", "c"]
      chart.d_lbls.show_val = true
      chart.d_lbls.d_lbl_pos = :outEnd
      chart.d_lbls.show_percent = true
    end

    ws.add_chart(Axlsx::Line3DChart, title: "axis labels") do |chart|
      chart.valAxis.title = 'bob'
      chart.d_lbls.show_val = true
    end

    ws.add_chart(Axlsx::Bar3DChart, title: 'bar chart') do |chart|
      chart.add_series data: [1, 4, 5], labels: %w(A B C)
      chart.d_lbls.show_percent = true
    end

    ws.add_chart(Axlsx::ScatterChart, title: 'scat man') do |chart|
      chart.add_series xData: [1, 2, 3, 4], yData: [4, 3, 2, 1]
      chart.d_lbls.show_val = true
    end

    ws.add_chart(Axlsx::BubbleChart, title: 'bubble chart') do |chart|
      chart.add_series xData: [1, 2, 3, 4], yData: [1, 3, 2, 4]
      chart.d_lbls.show_val = true
    end

    @fname = 'axlsx_test_serialization.xlsx'
    img = File.expand_path('fixtures/image1.jpeg', __dir__)
    ws.add_image(image_src: img, noSelect: true, noMove: true, hyperlink: "http://axlsx.blogspot.com") do |image|
      image.width = 720
      image.height = 666
      image.hyperlink.tooltip = "Labeled Link"
      image.start_at 5, 5
      image.end_at 10, 10
    end
    ws.add_image image_src: File.expand_path('fixtures/image1.gif', __dir__) do |image|
      image.start_at 0, 20
      image.width = 360
      image.height = 333
    end
    ws.add_image image_src: File.expand_path('fixtures/image1.png', __dir__) do |image|
      image.start_at 9, 20
      image.width = 180
      image.height = 167
    end
    ws.add_table 'A1:C1'

    ws.add_pivot_table 'G5:G6', 'A1:B3'

    ws.add_page_break "B2"
  end

  def test_use_autowidth
    @package.use_autowidth = false

    refute(@package.workbook.use_autowidth)
  end

  def test_core_accessor
    assert_equal(@package.core, Axlsx.instance_values_for(@package)["core"])
    assert_raise(NoMethodError) { @package.core = nil }
  end

  def test_app_accessor
    assert_equal(@package.app, Axlsx.instance_values_for(@package)["app"])
    assert_raise(NoMethodError) { @package.app = nil }
  end

  def test_use_shared_strings
    assert_nil(@package.use_shared_strings)
    assert_raise(ArgumentError) { @package.use_shared_strings 9 }
    assert_nothing_raised { @package.use_shared_strings = true }
    assert_equal(@package.use_shared_strings, @package.workbook.use_shared_strings)
  end

  def test_default_objects_are_created
    assert_kind_of(Axlsx::App, Axlsx.instance_values_for(@package)["app"], 'App object not created')
    assert_kind_of(Axlsx::Core, Axlsx.instance_values_for(@package)["core"], 'Core object not created')
    assert_kind_of(Axlsx::Workbook, @package.workbook, 'Workbook object not created')
    assert_empty(Axlsx::Package.new.workbook.worksheets, 'Workbook should not have sheets by default')
  end

  def test_created_at_is_propagated_to_core
    time = Time.utc(2013, 1, 1, 12, 0)
    p = Axlsx::Package.new created_at: time

    assert_equal(time, p.core.created)
  end

  def test_serialization
    @package.serialize(@fname)

    assert_zip_file_matches_package(@fname, @package)
    assert_created_with_rubyzip(@fname, @package)
    File.delete(@fname)
  end

  def test_serialization_with_zip_command
    @package.serialize(@fname, zip_command: "zip")

    assert_zip_file_matches_package(@fname, @package)
    assert_created_with_zip_command(@fname, @package)
    File.delete(@fname)
  end

  def test_serialization_with_zip_command_and_absolute_path
    fname = "#{Dir.tmpdir}/#{@fname}"
    @package.serialize(fname, zip_command: "zip")

    assert_zip_file_matches_package(fname, @package)
    assert_created_with_zip_command(fname, @package)
    File.delete(fname)
  end

  def test_serialization_with_invalid_zip_command
    assert_raises Axlsx::ZipCommand::ZipError do
      @package.serialize(@fname, zip_command: "invalid_zip")
    end
  end

  def test_serialize_automatically_performs_apply_styles
    p = Axlsx::Package.new
    wb = p.workbook

    assert_nil wb.styles_applied
    wb.add_worksheet do |sheet|
      sheet.add_row ['A1', 'B1']
      sheet.add_style 'A1:B1', b: true
    end

    @fname = 'axlsx_test_serialization.xlsx'

    p.serialize(@fname)

    assert wb.styles_applied
    assert_equal 1, wb.styles.style_index.count

    File.delete(@fname)
  end

  def test_serialize_with_password
    return unless RUBY_ENGINE == 'ruby'

    password = 'abc123'
    @package.serialize(@fname, password: password)

    decrypted_fname = 'axlsx_test_serialization_decrypted.xlsx'
    assert_nothing_raised { OoxmlCrypt.decrypt_file(@fname, password, decrypted_fname) }
    assert_zip_file_matches_package(decrypted_fname, @package)
    assert_created_with_rubyzip(decrypted_fname, @package)

    File.delete(@fname)
    File.delete(decrypted_fname)
  end

  def test_serialization_with_password_and_zip_command
    return unless RUBY_ENGINE == 'ruby'

    fname = "#{Dir.tmpdir}/#{@fname}"
    password = 'abc123'
    @package.serialize(fname, zip_command: 'zip', password: password)

    decrypted_fname = 'axlsx_test_serialization_decrypted.xlsx'
    assert_nothing_raised { OoxmlCrypt.decrypt_file(fname, password, decrypted_fname) }
    assert_zip_file_matches_package(decrypted_fname, @package)
    assert_created_with_zip_command(decrypted_fname, @package)

    File.delete(fname)
    File.delete(decrypted_fname)
  end

  # def test_serialize_with_password_no_ooxml_crypt
  #   hide_const('OoxmlCrypt')
  #   assert_raises(RuntimeError, 'Axlsx encryption requires ooxml_crypt gem') do
  #     @package.to_stream(password: 'abc123')
  #   end
  # end

  def assert_zip_file_matches_package(fname, package)
    zf = Zip::File.open(fname)
    package.send(:parts).each { |part| zf.get_entry(part[:entry]) }
  end

  def assert_created_with_rubyzip(fname, package)
    assert_equal 2098, get_mtime(fname, package).year, "XLSX files created with RubyZip have 2098 as the file mtime"
  end

  def assert_created_with_zip_command(fname, package)
    assert_equal Time.now.utc.year, get_mtime(fname, package).year, "XLSX files created with a zip command have the current year as the file mtime"
  end

  def get_mtime(fname, package)
    zf = Zip::File.open(fname)
    part = package.send(:parts).first
    entry = zf.get_entry(part[:entry])
    entry.mtime.utc
  end

  def test_serialization_with_deprecated_argument
    warnings = capture_warnings do
      @package.serialize(@fname, false)
    end

    assert_equal 1, warnings.size
    assert_includes warnings.first, "confirm_valid as a boolean is deprecated"
    File.delete(@fname)
  end

  def test_serialization_with_deprecated_three_arguments
    warnings = capture_warnings do
      @package.serialize(@fname, true, zip_command: "zip")
    end

    assert_zip_file_matches_package(@fname, @package)
    assert_created_with_zip_command(@fname, @package)
    assert_equal 2, warnings.size
    assert_includes warnings.first, "with 3 arguments is deprecated"
    File.delete(@fname)
  end

  # See comment for Package#zip_entry_for_part
  def test_serialization_creates_identical_files_at_any_time_if_created_at_is_set
    @package.core.created = Time.now
    zip_content_now = @package.to_stream.string
    Timecop.travel(3600) do
      zip_content_then = @package.to_stream.string

      assert_equal zip_content_then, zip_content_now, "zip files are not identical"
    end
  end

  def test_serialization_creates_identical_files_for_identical_packages
    package_1, package_2 = Array.new(2) do
      Axlsx::Package.new(created_at: Time.utc(2013, 1, 1)).tap do |p|
        p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
          sheet.add_row [1, 2, 3]
        end
      end
    end

    assert_equal package_1.to_stream.string, package_2.to_stream.string, "zip files are not identical"
  end

  def test_serialization_creates_files_with_excel_mime_type
    assert_equal('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', Marcel::MimeType.for(@package.to_stream))
  end

  def test_validation
    assert_equal(0, @package.validate.size, @package.validate)
    Axlsx::Workbook.send(:class_variable_set, :@@date1904, 9900)

    refute_empty(@package.validate)
  end

  def test_parts
    p = @package.send(:parts)
    # all parts have an entry
    assert_equal(1, p.count { |part| part[:entry].include?('_rels/.rels') }, "rels missing")
    assert_equal(1, p.count { |part| part[:entry].include?('docProps/core.xml') }, "core missing")
    assert_equal(1, p.count { |part| part[:entry].include?('docProps/app.xml') }, "app missing")
    assert_equal(1, p.count { |part| part[:entry].include?('xl/_rels/workbook.xml.rels') }, "workbook rels missing")
    assert_equal(1, p.count { |part| part[:entry].include?('xl/workbook.xml') }, "workbook missing")
    assert_equal(1, p.count { |part| part[:entry].include?('[Content_Types].xml') }, "content types missing")
    assert_equal(1, p.count { |part| part[:entry].include?('xl/styles.xml') }, "styles missin")
    assert_equal(p.count { |part| %r{xl/drawings/_rels/drawing\d\.xml\.rels}.match?(part[:entry]) }, @package.workbook.drawings.size, "one or more drawing rels missing")
    assert_equal(p.count { |part| %r{xl/drawings/drawing\d\.xml}.match?(part[:entry]) }, @package.workbook.drawings.size, "one or more drawings missing")
    assert_equal(p.count { |part| %r{xl/charts/chart\d\.xml}.match?(part[:entry]) }, @package.workbook.charts.size, "one or more charts missing")
    assert_equal(p.count { |part| %r{xl/worksheets/sheet\d\.xml}.match?(part[:entry]) }, @package.workbook.worksheets.size, "one or more sheet missing")
    assert_equal(p.count { |part| %r{xl/worksheets/_rels/sheet\d\.xml\.rels}.match?(part[:entry]) }, @package.workbook.worksheets.size, "one or more sheet rels missing")
    assert_equal(p.count { |part| %r{xl/comments\d\.xml}.match?(part[:entry]) }, @package.workbook.worksheets.size, "one or more sheet rels missing")
    assert_equal(p.count { |part| %r{xl/pivotTables/pivotTable\d\.xml}.match?(part[:entry]) }, @package.workbook.worksheets.first.pivot_tables.size, "one or more pivot tables missing")
    assert_equal(p.count { |part| %r{xl/pivotTables/_rels/pivotTable\d\.xml.rels}.match?(part[:entry]) }, @package.workbook.worksheets.first.pivot_tables.size, "one or more pivot tables rels missing")
    assert_equal(p.count { |part| %r{xl/pivotCache/pivotCacheDefinition\d\.xml}.match?(part[:entry]) }, @package.workbook.worksheets.first.pivot_tables.size, "one or more pivot tables missing")

    # no mystery parts
    assert_equal(25, p.size)

    # sorted for correct MIME detection
    assert_equal("[Content_Types].xml", p[0][:entry], "first entry should be `[Content_Types].xml`")
    assert_equal("_rels/.rels", p[1][:entry], "second entry should be `_rels/.rels`")
    assert_match(%r{\Axl/}, p[2][:entry], "third entry should begin with `xl/`")
  end

  def test_shared_strings_requires_part
    @package.use_shared_strings = true
    @package.to_stream # ensure all cell_serializer paths are hit
    p = @package.send(:parts)

    assert_equal(1, p.count { |part| part[:entry].include?('xl/sharedStrings.xml') }, "shared strings table missing")
  end

  def test_workbook_is_a_workbook
    assert_kind_of Axlsx::Workbook, @package.workbook
  end

  def test_base_content_types
    ct = @package.send(:base_content_types)

    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::RELS_CT }, "rels content type missing")
    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::XML_CT }, "xml content type missing")
    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::APP_CT }, "app content type missing")
    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::CORE_CT }, "core content type missing")
    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::STYLES_CT }, "styles content type missing")
    assert_equal(1, ct.count { |c| c.ContentType == Axlsx::WORKBOOK_CT }, "workbook content type missing")
    assert_equal(6, ct.size)
  end

  def test_content_type_added_with_shared_strings
    @package.use_shared_strings = true
    ct = @package.send(:content_types)

    assert_equal(1, ct.count { |type| type.ContentType == Axlsx::SHARED_STRINGS_CT })
  end

  def test_name_to_indices
    assert_equal([0, 0], Axlsx.name_to_indices('A1'))
    assert_equal([0, 99], Axlsx.name_to_indices('A100'), 'needs to axcept rows that contain 0')
  end

  def test_to_stream
    stream = @package.to_stream

    assert_kind_of(StringIO, stream)
    # this is just a roundabout guess for a package as it is build now
    # in testing.
    assert_operator(stream.size, :>, 80_000)
    # Stream (of zipped contents) should have appropriate default encoding
    assert_predicate stream.string, :valid_encoding?
    assert_equal(stream.external_encoding, Encoding::ASCII_8BIT)
    # Cached ids should be cleared
    assert_empty(Axlsx::Relationship.ids_cache)
  end

  def test_to_stream_automatically_performs_apply_styles
    p = Axlsx::Package.new
    wb = p.workbook

    assert_nil wb.styles_applied
    wb.add_worksheet do |sheet|
      sheet.add_row ['A1', 'B1']
      sheet.add_style 'A1:B1', b: true
    end

    p.to_stream

    assert_equal 1, wb.styles.style_index.count
  end

  def test_to_stream_with_password
    return unless RUBY_ENGINE == 'ruby'

    password = 'abc123'
    stream = @package.to_stream(password: password)

    assert_kind_of(StringIO, stream)
    assert_nothing_raised { OoxmlCrypt.decrypt(stream.read, password) }
  end

  # def test_to_stream_with_password_no_ooxml_crypt
  #   hide_const('OoxmlCrypt')
  #   assert_raises(RuntimeError, 'Axlsx encryption requires ooxml_crypt gem') do
  #     @package.to_stream(password: 'abc123')
  #   end
  # end
end
