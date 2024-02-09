# Caxlsx (Community Continued Version)
[![Test](https://github.com/caxlsx/caxlsx/actions/workflows/test.yml/badge.svg)](https://github.com/caxlsx/caxlsx/actions/workflows/test.yml)
[![RuboCop](https://github.com/caxlsx/caxlsx/actions/workflows/rubocop.yml/badge.svg)](https://github.com/caxlsx/caxlsx/actions/workflows/rubocop.yml)
[![Gem Version](https://badge.fury.io/rb/caxlsx.svg)](https://badge.fury.io/rb/caxlsx)
![downloads](https://img.shields.io/gem/dt/caxlsx?label=downloads)

## Notice: Community Axlsx Organization

To better maintain the Axlsx ecosystem, all related gems have been forked or moved to the following community organization:

https://github.com/caxlsx

[Join the Caxlsx Slack channel](https://join.slack.com/t/caxlsx/shared_invite/enQtOTI5OTM0MzI1Njk5LTBlMDQzNDk2YzkwODMxMmVkODMyYzJiZGU5NTQ3YTg5NTBlN2IwZTlmNTRjNzhiY2E0MDY2OTEyYmFlODI5NjA)

## Synopsis

Axlsx is an Office Open XML Spreadsheet generator for the Ruby programming language.
With Axlsx you can create Excel worksheets with charts, images (with links), automated and fixed column widths, customized styles, functions, tables, conditional formatting, print options, comments, merged cells, auto filters, file and stream serialization  as well as full schema validation. Axlsx excels at helping you generate beautiful Office Open XML Spreadsheet documents without having to understand the entire ECMA specification.

![Screen 1](https://github.com/caxlsx/caxlsx/raw/master/examples/sample.png)


## Feature List

1. Author xlsx documents: Caxlsx is made to let you easily and quickly generate professional xlsx based reports that can be validated before serialization.

2. Generate 3D Pie, Line, Scatter and Bar Charts: With Caxlsx chart generation and management is as easy as a few lines of code. You can build charts based off data in your worksheet or generate charts without any data in your sheet at all. Customize gridlines, label rotation and series colors as well.

3. Custom Styles: With guaranteed document validity, you can style borders, alignment, fills, fonts, and number formats in a single line of code. Those styles can be applied to an entire row, or a single cell anywhere in your workbook.

4. Automatic type support: Caxlsx will automatically determine the type of data you are generating. In this release Float, Integer, String, Date, Time and Boolean types are automatically identified and serialized to your spreadsheet.

5. Automatic and fixed column widths: Caxlsx will automatically determine the appropriate width for your columns based on the content in the worksheet, or use any value you specify for the really funky stuff.

6. Support for automatically formatted 1904 and 1900 epochs configurable in the workbook.

7. Add jpg, gif and png images to worksheets with hyperlinks

8. Reference cells in your worksheet with "A1" and "A1:D4" style references or from the workbook using "Sheet1!A3:B4" style references

9. Cell level style overrides for default and customized style objects

10. Support for formulas, merging, row and column outlining as well as
cell level input data validation.

12. Auto filtering tables with worksheet.auto_filter as well as support for Tables

13. Export using shared strings or inline strings so we can inter-op with iWork Numbers (sans charts for now).

14. Output to file or StringIO

15. Support for page margins and print options

16. Support for workbook-level encryption and password protection (requires [ooxml_crypt](https://github.com/teamsimplepay/ooxml_crypt) gem which only supports MRI Ruby.)

17. Support for sheet-level password and non-password protection.

18. First stage interoperability support for GoogleDocs, LibreOffice, and Numbers.

19. Support for defined names, which gives you repeated header rows for printing.

20. Data labels for charts as well as series color customization.

21. Support for sheet headers and footers

22. Pivot Tables

23. Page Breaks


## Install

```ruby
gem 'caxlsx'
```

**Supported Ruby versions:** Caxlsx supports Ruby 2.6 and newer.

## Usage

Here's a teaser that kicks about 2% of what the gem can do.

```ruby
Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
    sheet.add_row ["Simple Pie Chart"]
    %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
    sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
      chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
    end
  end
  p.serialize('simple.xlsx')
end
```

Please see the [examples folder](https://github.com/caxlsx/caxlsx/tree/master/examples) for further information on what you can do with this gem  Chances are that it has already been implemented. If it hasn't, let's take a look at adding it in.

## Documentation

Detailed documentation is available at:

[https://www.rubydoc.info/gems/caxlsx/](https://www.rubydoc.info/gems/caxlsx/)

Additional documentation is listed below:

- [Examples](https://github.com/caxlsx/caxlsx/tree/master/examples)
- [FAQ](https://github.com/caxlsx/caxlsx/wiki/FAQ) (work in progress)
- [Style Reference](https://github.com/caxlsx/caxlsx/blob/master/docs/style_reference.md)
- [Header and Footer Codes](https://github.com/caxlsx/caxlsx/blob/master/docs/header_and_footer_codes.md)

⚠ Please __do not create issues__ for questions regarding the usage of axlsx / caxlsx. Look through this README, the [examples](https://github.com/caxlsx/caxlsx/tree/master/examples/example.rb), and the [FAQ](https://github.com/caxlsx/caxlsx/wiki/FAQ), and also check [questions tagged `axlsx` on Stack Overflow](https://stackoverflow.com/questions/tagged/axlsx).

Feel free to add your question (including an answer!) to the FAQ if you think it is of general interest.

## Plugins, Integrations, and Extensions

Currently the following additional gems are available:

- [acts_as_caxlsx](https://github.com/caxlsx/acts_as_caxlsx)
  * Provides simple ActiveRecord integration
- [caxlsx_rails](https://github.com/caxlsx/caxlsx_rails)
  * Provides a `.axlsx` renderer to Rails so you can move all your spreadsheet code from your controller into view files.
- [activeadmin-caxlsx](https://github.com/caxlsx/activeadmin-caxlsx)
  * An Active Admin plugin that includes DSL to create downloadable reports.
- [ooxml_crypt](https://github.com/teamsimplepay/ooxml_crypt)
  * Required to enable workbook encryption and password protection.

## Security

To prevent [Formula Injection](https://www.owasp.org/index.php/CSV_Injection) vulnerabilities, as of version 4.0, axlsx escapes all formulas by default. To permit formulas on a specific cell, please use:

```ruby
cell.escape_formulas = false
```

You may set `escape_formulas` on the workbook, worksheet, row and/or cell level. Refer to examples/escape_formula.md for details.

To allow formulas globally by default (which was the behavior in axlsx 3.x and prior), you may set the following in an initializer:

```ruby
Axlsx.escape_formulas = false
```

## Known Software Interoperability Issues

As axslx implements the Office Open XML (ECMA-376 spec) much of the
functionality is interoperable with other spreadsheet software. Below is
a listing of some known issues.

1. Libre Office
   -  You must specify colors for your series. see examples/chart_colors.rb
for an example.
   - You must use data in your sheet for charts. You cannot use hard coded
values.
   -  Chart axis and gridlines do not render. I have a feeling this is
related to themes, which axlsx does not implement at this time.

2. Google Docs
   - Images are known to not work with google docs
   - border colors do not work

3. Apple Numbers
   - charts do not render
   - you must set 'use_shared_strings' to true. This is most conveniently done just before rendering by calling Package.use_shared_strings = true prior to serialization.

```ruby
p = Axlsx::Package.new
p.workbook.add_worksheet(:name => "Basic Worksheet") do |sheet|
  sheet.add_row ["First Column", "Second", "Third"]
  sheet.add_row [1, 2, 3]
end
p.use_shared_strings = true
p.serialize('simple.xlsx')
```

## Contributing

See [CONTRIBUTING.md](https://github.com/caxlsx/caxlsx/blob/master/CONTRIBUTING.md)

## Credits

Originally created by Randy Morgan - @randym

Forked in 2019, to enable the community to maintain the Axlsx ecosystem - https://github.com/caxlsx

Open source software is a community effort. None of this could have been done without the help of [our Contributors](https://github.com/caxlsx/caxlsx/graphs/contributors).
