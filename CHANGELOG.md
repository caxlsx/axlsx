CHANGELOG
---------
- **Unreleased**
  - [PR #350](https://github.com/caxlsx/caxlsx/pull/350) Add package-level encryption and password protection
  - [PR #316](https://github.com/caxlsx/caxlsx/pull/316) Prevent camelization of hyperlink locations
  - [PR #312](https://github.com/caxlsx/caxlsx/pull/312) Added 2D/flat PieChart drawing
  - [PR #317](https://github.com/caxlsx/caxlsx/pull/317) Apply style for columns without defining cells
  - [PR #345](https://github.com/caxlsx/caxlsx/pull/345) Show outline symbols by default to match original behavior
  - [PR #334](https://github.com/caxlsx/caxlsx/pull/334) Add pattern fill options to add_style
  - [PR #342](https://github.com/caxlsx/caxlsx/pull/342) Fix show button for filter columns

- **October.30.23**: 4.0.0
  - [PR #189](https://github.com/caxlsx/caxlsx/pull/189) **breaking** Make `Axlsx::escape_formulas` true by default to mitigate [Formula Injection](https://www.owasp.org/index.php/CSV_Injection) vulnerabilities.
  - [PR #212](https://github.com/caxlsx/caxlsx/pull/212) **breaking** Raise exception if `axlsx_styler` gem is present as its code was merged directly into `caxlsx` in v3.3.0
  - [PR #225](https://github.com/caxlsx/caxlsx/pull/225) **breaking** Remove ability to set `u=` to true in favor of using :single or one of the other underline options
  - Drop support for Ruby versions < 2.6
  - [PR #219](https://github.com/caxlsx/caxlsx/pull/219) Added frozen string literals
  - [PR #223](https://github.com/caxlsx/caxlsx/pull/223) Fix `SimpleTypedList#to_a` and `SimpleTypedList#to_ary` returning the internal list instance
  - [PR #239](https://github.com/caxlsx/caxlsx/pull/239) Fix `Workbook#sheet_by_name` not returning sheets with encoded characters in the name
  - [PR #286](https://github.com/caxlsx/caxlsx/pull/286) Add 'SortState' and 'SortCondition' classes to the 'AutoFilter' class to add sorting to the generated file.
  - [PR #269](https://github.com/caxlsx/caxlsx/pull/269) Add optional interpolation points to icon sets
  - [PR #304](https://github.com/caxlsx/caxlsx/pull/304) Fix data validations for none type validations

- **April.23.23**: 3.4.1
  - [PR #209](https://github.com/caxlsx/caxlsx/pull/209) - Revert characters other than `=` being considered as formulas.

- **April.12.23**: 3.4.0
  - [PR #186](https://github.com/caxlsx/caxlsx/pull/186) - Add `escape_formulas` to global, workbook, worksheet, row and cell levels, and standardize behavior.
  - [PR #186](https://github.com/caxlsx/caxlsx/pull/186) - `escape_formulas` should handle all [OWASP-designated formula prefixes](https://owasp.org/www-community/attacks/CSV_Injection).
  - Fix bug when calling `worksheet.add_border("A1:B2", nil)`
  - Change `BorderCreator#initialize` arguments handling
  - Fix `add_border` to work with singluar cell refs
  - [PR #196](https://github.com/caxlsx/caxlsx/pull/196) - Fix tab color reassignment
  - Add support for remote image source in `Pic` using External Relationship (supported in Excel documents)

- **October.21.22**: 3.3.0
  - [PR #168](https://github.com/caxlsx/caxlsx/pull/168) - Merge in the gem [`axlsx_styler`](https://github.com/axlsx-styler-gem/axlsx_styler)
    - Add ability to both apply or append to existing styles after rows have been created using `worksheet.add_style`
      - `worksheet.add_style "A1", {b: true}`
      - `worksheet.add_style "A1:B2", {b: true}`
      - `worksheet.add_style ["A1", "B2:C7", "D8:E9"], {b: true}`
    - Add ability to create borders upon specific areas of the page using `worksheet.add_border`
      - `worksheet.add_border "A1", {style: :thin}`
      - `worksheet.add_border "A1:B2", {style: :thin}`
      - `worksheet.add_border ["A1", "B2:C7", "D8:E9"], {style: :thin}`
    - Add `Axlsx::BorderCreator` the class used under the hood for `worksheet.add_border`
    - Allow specifying `:all` in `border: {edges: :all}` which is a shortcut for `border: {edges: [:left, :right, :top, :bottom]}`
  - [PR #156](https://github.com/caxlsx/caxlsx/pull/156) - Prevent Excel from crashing when multiple data columns added to PivotTable
  - [PR #155](https://github.com/caxlsx/caxlsx/pull/155) - Add `hideDropDown` alias for `showDropDown` setting, as the latter is confusing to use (because its logic seems inverted).
  - [PR #143](https://github.com/caxlsx/caxlsx/pull/143) - Add setting `sort_on_headers` for pivot tables
  - [PR #132](https://github.com/caxlsx/caxlsx/pull/132) - Remove monkey patch from Object#instance_values
  - [PR #139](https://github.com/caxlsx/caxlsx/pull/139) - Sort archive entries for correct MIME detection with `file` command
  - [PR #140](https://github.com/caxlsx/caxlsx/pull/140) - Update gemspec to recent styles - it reduced the size of the gem
  - [PR #147](https://github.com/caxlsx/caxlsx/pull/147) - Implement “rounded corners” setting for charts.
  - [PR #145](https://github.com/caxlsx/caxlsx/pull/145) - Implement “plot visible only” setting for charts.
  - [PR #144](https://github.com/caxlsx/caxlsx/pull/144) - Completely hide chart titles if blank; Fix missing cell reference for chart title when cell empty.

- **February.23.22**: 3.2.0
  - [PR #75](https://github.com/caxlsx/caxlsx/pull/85) - Added manageable markers for scatter series
  - [PR #116](https://github.com/caxlsx/caxlsx/pull/116) - Validate name option to be non-empty string when passed.
  - [PR #117](https://github.com/caxlsx/caxlsx/pull/117) - Allow passing an Array of border hashes to the `border` style. Change previous behaviour where `border_top`, `border_*` styles would not be applied unless `border` style was also defined.
  - [PR #122](https://github.com/caxlsx/caxlsx/pull/122) - Improve error messages when incorrect ranges are provided to `Worksheet#[]`
  - [PR #123](https://github.com/caxlsx/caxlsx/pull/123) - Fix invalid xml when pivot table created with more than one column in data field. Solves [Issue #110](https://github.com/caxlsx/caxlsx/issues/110)
  - [PR #127](https://github.com/caxlsx/caxlsx/pull/127) - Possibility to configure the calculation of the autowidth mechanism with `font_scale_divisor` and `bold_font_multiplier`. Example: [Fine tuned autowidth](examples/fine_tuned_autowidth_example.md)
  - [PR #85](https://github.com/caxlsx/caxlsx/pull/85) - Manageable markers for scatter series
  - [PR #120](https://github.com/caxlsx/caxlsx/pull/120) - Return output stream in binmode

- **September.22.21**: 3.1.1
  - [PR #107](https://github.com/caxlsx/caxlsx/pull/107) - Add overlap to bar charts
  - [PR #108](https://github.com/caxlsx/caxlsx/pull/108) - Fix gap depth and gap depth validators for bar charts and 3D bar charts
  - [PR #94](https://github.com/caxlsx/caxlsx/pull/94) - Major performance improvement for charts with large amounts of data
  - [PR #81](https://github.com/caxlsx/caxlsx/pull/81) - Add option to define a color for the BarSeries

- **March.27.21**: 3.1.0
  - [PR #95](https://github.com/caxlsx/caxlsx/pull/95) - Replace mimemagic with marcel
  - [PR #87](https://github.com/caxlsx/caxlsx/pull/87) - Implement :offset option for worksheet#add_row
  - [PR #79](https://github.com/caxlsx/caxlsx/pull/79) - Add support for format in pivot tables
  - [PR #77](https://github.com/caxlsx/caxlsx/pull/77) - Fix special characters in table header
  - [PR #57](https://github.com/caxlsx/caxlsx/pull/57) - Deprecate using #serialize with boolean argument: Calls like `Package#serialize("name.xlsx", false)` should be replaced with `Package#serialize("name.xlsx", confirm_valid: false)`.
  - [PR #78](https://github.com/caxlsx/caxlsx/pull/78) - Fix special characters in pivot table cache definition
  - [PR #84](https://github.com/caxlsx/caxlsx/pull/84) - Add JRuby 9.2 to the CI

- **January.5.21**: 3.0.4
  - [PR #72](https://github.com/caxlsx/caxlsx/pull/72) - Relax Ruby dependency to allow for Ruby 3. This required Travis to be upgraded from Ubuntu Trusty to Ubuntu Bionic. rbx-3 was dropped.
  - [PR #71](https://github.com/caxlsx/caxlsx/pull/71) - Adds date type to validator so sheet.add_data_validation works with date type. Addresses [I #26](https://github.com/caxlsx/caxlsx/issues/26) - Date Data Validation not working
  - [PR #70](https://github.com/caxlsx/caxlsx/pull/70) - Fix worksheet title length enforcement caused by switching from size to bytesize. Addresses [I #67](https://github.com/caxlsx/caxlsx/issues/67) - character length error in worksheet name when using Japanese, which was introduced by addressing [I #588](https://github.com/randym/axlsx/issues/588) in the old Axlsx repo.


- **December.7.20**: 3.0.3
  - [PR #62](https://github.com/caxlsx/caxlsx/pull/62) - Fix edge cases in format detection for objects whose string representation made them look like numbers but the object didn’t respond to `#to_i` or `#to_f`.
  - [PR #56](https://github.com/caxlsx/caxlsx/pull/56) - Add `zip_command` option to `#serialize` for faster serialization of large Excel files by using a zip binary
  - [PR #54](https://github.com/caxlsx/caxlsx/pull/54) - Fix type detection for floats with out-of-rage exponents
  - [I #67](https://github.com/caxlsx/caxlsx/issues/67) - Fix regression in worksheet name length enforcement: Some unicode characters were counted incorrectly, so that names that previously worked fine now stopped working. (This was introduced in 3.0.2)
  - [I #58](https://github.com/caxlsx/caxlsx/issues/58) - Fix explosion for pie chart throwing error
  - [PR #60](https://github.com/caxlsx/caxlsx/pull/60) - Add Ruby 2.7 to the CI
  - [PR #47](https://github.com/caxlsx/caxlsx/pull/47) - Restructure examples folder

- **July.16.20**: 3.0.2
  - [I #51](https://github.com/caxlsx/caxlsx/issues/51) - Images do not import on Windows. IO read set explicitly to binary mode.
  - [PR #53](https://github.com/caxlsx/caxlsx/pull/53) - Limit column width to 255. Maximum column width limit in MS Excel is 255 characters, see https://support.microsoft.com/en-us/office/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3
  - [PR #44](https://github.com/caxlsx/caxlsx/pull/44) - Improve cell autowidth calculations. Previously columns with undefined/auto width would tend to be just slightly too small for the content. This is because certain letters were being excluded from the width calculation because they were deemed not wide enough. We now treat all characters as equal width which helps ensure columns auto-widths are actually large enough for the content. This will gain us a very slight performance improvement because of we are no longer searching the string for specific characters.
  - [PR #40](https://github.com/caxlsx/caxlsx/pull/40) - Escape special characters in charts
  - [PR #34](https://github.com/caxlsx/caxlsx/pull/34) - Add option to protect against csv injection attacks

- **October.4.19**: 3.0.1
  - Support for ruby versions limited to officially supported version (Ruby v2.3+)
  - Updates to dependency gems, especially nokogiri and ruby-zip
  - Fix Relationship.instances cache
  - Autoload fix for Rails

- **October.4.19**: 2.0.2
  - Released as caxlsx, fork of axlsx
  - Update ruby-zip dependency (fixes https://github.com/randym/axlsx/issues/536)

- **September.17.19**: 3.0.0
  - First release of caxlsx, fork of axlsx

- **April.1.17**: 3.0.0-pre
  - Support for ruby versions limited to officially supported version
  - Updates to dependency gems, especially nokogiri and ruby-zip
  - Patch options parsing for two cell anchor
  - Remove support for depreciated worksheet members
  - Added Cell#name so you you can quickly create a defined name for a single cell in your workbook.
  - Added full book view and sheet state management. This means you can specify how the workbook renders as well as manage sheet visibility.
  - Added smoothing management for line charts series

- **September.12.13**: 2.0.1
  - Unpinned rubyzip version

- **September.12.13**: 2.0.0
  - DROPPED support for ruby 1.8.7
  - Altered readme to link to contributors
  - Lots of improvements to make charts and relations more stable.
  - Patched color param mutation.
  - Data sourced for pivot tables can now come from other sheets.
  - Altered image file extension comparisons to be case insensitive.
  - Added control character sanitization to shared strings.
  - Added page breaks. see examples/example.rb for an example.
  - Bugfix: single to dual cell anchors for images now swap properly so you can set the end_at position during instantiation, in a block or directly on the image.
  - Improved how we convert date/time to include the UTC offset when provided.
  - Pinned rubyzip to 0.9.9 for those who are not ready to go up. Please note that release 2.0.1 and on will be using the 1.n.n series of rubyzip
  - Bugfix: transposition of cells for Worksheet#cols now supports
    incongruent column counts.counts
  - Added space preservation for cell text. This will allow whitespace
    in cell text both when using shared strings and when serializing
    directly to the cell.

- **April.24.13**: 1.3.6
  - Fixed LibreOffice/OpenOffice issue to properly apply colors to lines
    in charts.
  - Added support for specifying between/notBetween formula in an array.
    *thanks* straydogstudio!
  - Added standard line chart support. *thanks* scambra
  - Fixed straydogstudio's link in the README. *thanks* nogara!

- **February.4.13**: 1.3.5
  - converted vary_colors for chart data to instance variable with appropriate defulats for the various charts.
  - Added trust_input method on Axlsx to instruct the serializer to skip HTML escaping. This will give you a tremendous performance boost,
    Please be sure that you will never have <, >, etc in your content or the XML will be invalid.
  - Rewrote cell serialization to improve performance
  - Added iso_8601 type to support text based date and time management.
  - Bug fix for relationship management in drawings when you add images
    and charts to the same worksheet drawing.
  - Added outline_level_rows and outline_level_columns to worksheet to simplify setting up outlining in the worksheet.
  - Added support for pivot tables
  - Added support for descrete border edge styles
  - Improved validation of sheet names
  - Added support for formula value caching so that iOS and OSX preview can show the proper values. See Cell.add_row and the formula_values option.

- **November.25.12**: 1.3.4
  - Support for headers and footers for worksheets
  - bug fix: Properly escape hyperlink urls
  - Improvements in color_scale generation for conditional formatting
  - Improvements in autowidth calculation.

- **November.8.12**: 1.3.3
  - Patched cell run styles for u and validation for family

- **November.5.12**: 1.3.2
  - MASSIVE REFACTORING
  - Patch for apostrophes in worksheet names
  - added sheet_by_name for workbook so you can now find your worksheets
    by name
  - added insert_worksheet so you can now add a worksheet to an
    arbitrary position in the worksheets list.
  - reduced memory consumption for package parts post serialization

- **September.30.12**: 1.3.1
  - Improved control character handling
  - Added stored auto filter values and date grouping items
  - Improved support for autowidth when custom styles are applied
  - Added support for table style info that lets you take advantage of
    all the predefined table styles.
  - Improved style management for fonts so they merge undefined values
    from the initial master.

- **September.8.12**: 1.2.3
  - enhance exponential float/bigdecimal values rendering as strings intead
    of 'numbers' in excel.
  - added support for :none option on chart axis labels
  - added support for paper_size option on worksheet.page_setup

- **August.27.12**: 1.2.2
   - minor patch for auto-filters
   - minor documentation improvements.

- **August.12.12**: 1.2.1
   - Add support for hyperlinks in worksheets
   - Fix example that was using old style cell merging with concact.
   - Fix bug that occurs when calculating the font_size for cells that use a user specified style which does not define sz

- **August.5.12**: 1.2.0
   - rebuilt worksheet serialization to clean up the code base a bit.
   - added data labels for charts
   - added table header printing for each sheet via defined_name. This
     means that when you print your worksheet, the header rows show for every page

- **July.??.12**: 1.1.9
   - lots of code clean up for worksheet
   - added in data labels for pie charts, line charts and bar charts.
   - bugfix chard with data in a sheet that has a space in the name are
     now auto updating formula based values

- **July.14.12**: 1.1.8
   - added html entity encoding for sheet names. This allows you to use
     characters like '<' and '&' in your sheet names.
   - new - first round google docs interoperability
   - added filter to strip out control characters from cell data.
   - added in interop requirements so that charts are properly exported
     to PDF from Libra Office
   - various readability improvements and work standardizing attribute
     names to snake_case. Aliases are provided for backward compatiblity

- **June.11.12**: 1.1.7
   - fix chart rendering issue when label offset is specified as a
     percentage in serialization and ensure that formula are not stored
in value caches
   - fix bug that causes repair warnings when using a text only title reference.
   - Add title property to axis so you can lable the x/y/series axis for
     charts.
   - Add sheet views with panes

- **May.30.12**: 1.1.6
   - data protection with passwords for sheets
   - cell level input validators
   - added support for two cell anchors for images
   - test coverage now back up to 100%
   - bugfix for merge cell sorting algorithm
   - added fit_to method for page_setup to simplify managing witdh/height
   - added ph (phonetics) and s (style) attributes for row.
   - resolved all warnings generating from this gem.
   - improved comment relationship management for multiple comments

- **May.13.12**: 1.1.5
   - MOAR print options! You can now specify paper size, orientation,
     fit to width, page margings and gridlines for printing.
   - Support for adding comments to your worksheets
   - bugfix for applying style to empty cells
   - bugfix for parsing formula with multiple '='

- **May.3.12:**: 1.1.4
   - MOAR examples
   - added outline level for rows and columns
   - rebuild of numeric and axis data sources for charts
   - added delete to axis
   - added tick and label mark skipping for cat axis in charts
   - bugfix for table headers method
   - sane(er) defaults for chart positioning
   - bugfix in val_axis_data to properly serialize value axis data. Excel does not mind as it reads from the sheet, but nokogiri has a fit if the elements are empty.
   - Added support for specifying the color of data series in charts.
   - bugfix using add_cell on row mismanaged calls to update_column_info.

- **April.25.12:**: 1.1.3
   - Primarily because I am stupid.....Updates to readme to properly report version, add in missing docs and restructure example directory.

- **April.25.12:**: 1.1.2
   - Conditional Formatting completely implemented.
   - refactoring / documentation for Style#add_style
   - added in label rotation for chart axis labels
   - bugfix to properly assign style and type info to cells when only partial information is provided in the types/style option

- **April.18.12**: 1.1.1
   - bugfix for autowidth calculations across multiple rows
   - bugfix for dimension calculations with nil cells.
   - REMOVED RMAGICK dependency WOOT!
   - Update readme to show screenshot of gem output.
   - Cleanup benchmark and add benchmark rake task

- **April.3.12**: 1.1.0
   - bugfix patch name_to_indecies to properly handle extended ranges.
   - bugfix properly serialize chart title.
   - lower rake minimum requirement for 1.8.7 apps that don't want to move on to 0.9 NOTE this will be reverted for 2.0.0 with workbook parsing!
   - Added Fit to Page printing
   - added support for turning off gridlines in charts.
   - added support for turning off gridlines in worksheet.
   - bugfix some apps like libraoffice require apply[x] attributes to be true. applyAlignment is now properly set.
   - added option use_autowidth. When this is false RMagick will not be loaded or used in the stack. However it is still a requirement in the gem.
   - added border style specification to styles#add_style. See the example in the readme.
   - Support for tables added in - Note: Pre 2011 versions of Mac office do not support this feature and will warn.
   - Support for splatter charts added
   - Major (like 7x faster!) performance updates.
   - Gem now supports for JRuby 1.6.7, as well as experimental support for Rubinius

- **March.5.12**: 1.0.18
   https://github.com/randym/axlsx/compare/1.0.17...1.0.18
   - bugfix custom borders are not properly applied when using styles.add_style
   - interop worksheet names must be 31 characters or less or some versions of office complain about repairs
   - added type support for :boolean and :date types cell values
   - added support for fixed column widths
   - added support for page_margins
   - added << alias for add_row
   - removed presetting of date1904 based on authoring platform. Now defaults to use 1900 epoch (date1904 = false)

- **February.14.12**: 1.0.17
   https://github.com/randym/axlsx/compare/1.0.16...1.0.17
   - Added in support for serializing to StringIO
   - Added in support for using shared strings table. This makes most of the features in axlsx interoperable with iWorks Numbers
   - Added in support for fixed column_widths
   - Removed unneeded dependencies on active-support and i18n

- **February.2.12**: 1.0.16
   https://github.com/randym/axlsx/compare/1.0.15...1.0.16
   - Bug fix for schema file locations when validating in rails
   - Added hyperlink to images
   - date1904 now automatically set in BSD and mac environments
   - removed whitespace/indentation from xml outputs
   - col_style now skips rows that do not contain cells at the column index

- **January.6.12**: 1.0.15
   https://github.com/randym/axlsx/compare/1.0.14...1.0.15
   - Bug fix add_style specified number formats must be explicity applied for libraOffice
   - performance improvements from ochko when creating cells with options.
   - Bug fix setting types=>[:n] when adding a row incorrectly determines the cell type to be string as the value is null during creation.
   - Release in preparation for password protection merge

- **December.14.11**: 1.0.14
   - Added support for merging cells
   - Added support for auto filters
   - Improved auto width calculations
   - Improved charts
   - Updated examples to output to a single workbook with multiple sheets
   - Added access to app and core package objects so you can set the creator and other properties of the package
   - The beginning of password protected xlsx files - roadmapped for January release.

- **December.8.11**: 1.0.13
   -  Fixing .gemspec errors that caused gem to miss the lib directory. Sorry about that.

- **December.7.11**: 1.0.12
    DO NOT USE THIS VERSION = THE GEM IS BROKEN
  - changed dependency from 'zip' gem to 'rubyzip' and added conditional code to force binary encoding to resolve issue with excel 2011
  - Patched bug in app.xml that would ignore user specified properties.
- **December.5.11**: 1.0.11
  - Added [] methods to worksheet and workbook to provide name based access to cells.
  - Added support for functions as cell values
  - Updated color creation so that two character shorthand values can be used like 'FF' for 'FFFFFFFF' or 'D8' for 'FFD8D8D8'
  - Examples for all this fun stuff added to the readme
  - Clean up and support for 1.9.2 and travis integration
  - Added support for string based cell referencing to chart start_at and end_at. That means you can now use :start_at=>"A1" when using worksheet.add_chart, or chart.start_at ="A1" in addition to passing a cell or the x, y coordinates.

- **October.30.11**: 1.0.10
  - Updating gemspec to lower gem version requirements.
  - Added row.style assignation for updating the cell style for an entire row
  - Added col_style method to worksheet upate a the style for a column of cells
  - Added cols for an easy reference to columns in a worksheet.
  - prep for pre release of acts_as_xlsx gem
  - added in travis.ci configuration and build status
  - fixed out of range bug in time calculations for 32bit time.
  - added i18n for active support

- **October.26.11**: 1.0.9
  - Updated to support ruby 1.9.3
  - Updated to eliminate all warnings originating in this gem

- **October.23.11**: 1.0.8
  - Added support for images (jpg, gif, png) in worksheets.

- **October.23.11**: 1.0.7 released
  - Added support for 3D options when creating a new chart. This lets you set the persective, rotation and other 3D attributes when using worksheet.add_chart
  - Updated serialization write test to verify write permissions and warn if it cannot run the test due to permission restrcitions.
  - updated rake to include build, genoc and deploy tasks.
  - rebuilt documentation.
  - moved version constant to its own file
  - fixed bug in SerAxis that was requiring tickLblSkip and tickMarkSkip to be boolean. Should be unsigned int.
  - Review and improve docs
  - rebuild of anchor positioning to remove some spagetti code. Chart now supports a start_at and end_at method that accept an arrar for col/row positioning. See example6 for an example. You can still pass :start_at and :end_at options to worksheet.add_chart.
  - Refactored cat and val axis data to keep series serialization a bit more DRY

- **October.22.11**: 1.0.6
  - Bumping version to include docs. Bug in gemspec pointing to incorrect directory.

- **October.22.11**: 1.05
  - Added support for line charts
  - Updated examples and readme
  - Updated series title to be a real title ** NOTE ** If you are accessing titles directly you will need to update text assignation.
         chart.series.first.title = 'Your Title'
         chart.series.first.title.text = 'Your Title'
    With this change you can assign a cell for the series title
         chart.series.title = sheet.rows.first.cells.first
    If you are using the recommended
         chart.add_series :data=>[], :labels=>[], :title
    You do not have to change anything.
  - BugFix: shape attribute for bar chart is now properly serialized
  - BugFix: date1904 property now properly set for charts
  - Added style property to charts
  - Removed serialization write test as it most commonly fails when run from the gem's intalled directory

- **October.21.11**: 1.0.4
  - altered package to accept a filename string for serialization instead of a File object.
  - Updated specs to conform
  - More examples for readme


- **October.21.11**: 1.0.3
  - Updated documentation

- **October.20.11**: 0.1.0
