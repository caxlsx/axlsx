# frozen_string_literal: true

module Axlsx
  # Package is responsible for managing all the bits and peices that Open Office XML requires to make a valid
  # xlsx document including validation and serialization.
  class Package
    include Axlsx::OptionsParser

    # provides access to the app doc properties for this package
    # see App
    attr_reader :app

    # provides access to the core doc properties for the package
    # see Core
    attr_reader :core

    # Initializes your package
    #
    # @param [Hash] options A hash that you can use to specify the author and workbook for this package.
    # @option options [String] :author The author of the document
    # @option options [Time] :created_at Timestamp in the document properties (defaults to current time).
    # @option options [Boolean] :use_shared_strings This is passed to the workbook to specify that shared strings should be used when serializing the package.
    # @example Package.new :author => 'you!', :workbook => Workbook.new
    def initialize(options = {})
      @workbook = nil
      @core, @app = Core.new, App.new
      @core.creator = options[:author] || @core.creator
      @core.created = options[:created_at]
      parse_options options
      yield self if block_given?
    end

    # Shortcut to specify that the workbook should use autowidth
    # @see Workbook#use_autowidth
    def use_autowidth=(v)
      Axlsx.validate_boolean(v)
      workbook.use_autowidth = v
    end

    # Shortcut to determine if the workbook is configured to use shared strings
    # @see Workbook#use_shared_strings
    def use_shared_strings
      workbook.use_shared_strings
    end

    # Shortcut to specify that the workbook should use shared strings
    # @see Workbook#use_shared_strings
    def use_shared_strings=(v)
      Axlsx.validate_boolean(v)
      workbook.use_shared_strings = v
    end

    # The workbook this package will serialize or validate.
    # @return [Workbook] If no workbook instance has been assigned with this package a new Workbook instance is returned.
    # @raise ArgumentError if workbook parameter is not a Workbook instance.
    # @note As there are multiple ways to instantiate a workbook for the package,
    #   here are a few examples:
    #     # assign directly during package instanciation
    #     wb = Package.new(:workbook => Workbook.new).workbook
    #
    #     # get a fresh workbook automatically from the package
    #     wb = Pacakge.new().workbook
    #     #     # set the workbook after creating the package
    #     wb = Package.new().workbook = Workbook.new
    def workbook
      @workbook || @workbook = Workbook.new
      yield @workbook if block_given?
      @workbook
    end

    # @see workbook
    def workbook=(workbook)
      DataTypeValidator.validate :Package_workbook, Workbook, workbook
      @workbook = workbook
    end

    # Serialize your workbook to disk as an xlsx document.
    #
    # @param [String] output The name of the file you want to serialize your package to
    # @param [Hash] options
    # @option options [Boolean] :confirm_valid Validate the package prior to serialization.
    # @option options [String] :zip_command When `nil`, `#serialize` with RubyZip to
    #   zip the XLSX file contents. When a String, the provided zip command (e.g.,
    #   "zip") is used to zip the file contents (may be faster for large files)
    # @option options [String] :password When specified, the serialized packaged will be
    #   encrypted with the password. Requires ooxml_crypt gem.
    # @return [Boolean] False if confirm_valid and validation errors exist. True if the package was serialized
    # @note A tremendous amount of effort has gone into ensuring that you cannot create invalid xlsx documents.
    #   options[:confirm_valid] should be used in the rare case that you cannot open the serialized file.
    # @see Package#validate
    # @example
    #   # This is how easy it is to create a valid xlsx file. Of course you might want to add a sheet or two, and maybe some data, styles and charts.
    #   # Take a look at the README for an example of how to do it!
    #
    #   #serialize to a file
    #   p = Axlsx::Package.new
    #   # ......add cool stuff to your workbook......
    #   p.serialize("example.xlsx")
    #
    #   # Serialize to a file, using a system zip binary
    #   p.serialize("example.xlsx", zip_command: "zip", confirm_valid: false)
    #   p.serialize("example.xlsx", zip_command: "/path/to/zip")
    #   p.serialize("example.xlsx", zip_command: "zip -1")
    #
    #   # Serialize to a stream
    #   s = p.to_stream()
    #   File.open('example_streamed.xlsx', 'wb') { |f| f.write(s.read) }
    def serialize(output, options = {}, secondary_options = nil)
      unless workbook.styles_applied
        workbook.apply_styles
      end

      confirm_valid, zip_command, password = parse_serialize_options(options, secondary_options)
      return false unless !confirm_valid || validate.empty?

      zip_provider = if zip_command
                       ZipCommand.new(zip_command)
                     else
                       BufferedZipOutputStream
                     end
      Relationship.initialize_ids_cache
      zip_provider.open(output) do |zip|
        write_parts(zip)
      end

      if password && !password.empty?
        ensure_ooxml_crypt!
        OoxmlCrypt.encrypt_file(output, password, output)
      end

      true
    ensure
      Relationship.clear_ids_cache
    end

    # Serialize your workbook to a StringIO instance
    # @param [Boolean] old_confirm_valid (Deprecated) Validate the package prior to serialization.
    #   Use :confirm_valid keyword arg instead.
    # @option kwargs [Boolean] :confirm_valid Validate the package prior to serialization.
    # @option kwargs [String] :password When specified, the serialized packaged will be
    #   encrypted with the password. Requires ooxml_crypt gem.
    # @return [StringIO|Boolean] False if confirm_valid and validation errors exist. Rewound string IO if not.
    def to_stream(old_confirm_valid = nil, confirm_valid: false, password: nil)
      unless old_confirm_valid.nil?
        warn "[DEPRECATION] Axlsx::Package#to_stream with confirm_valid as a non-keyword arg is deprecated. " \
             "Use keyword arg instead e.g., package.to_stream(confirm_valid: false)"
        confirm_valid ||= old_confirm_valid
      end

      unless workbook.styles_applied
        workbook.apply_styles
      end

      return false unless !confirm_valid || validate.empty?

      Relationship.initialize_ids_cache
      stream = BufferedZipOutputStream.write_buffer do |zip|
        write_parts(zip)
      end
      stream.rewind

      if password && !password.empty?
        ensure_ooxml_crypt!
        stream = StringIO.new(OoxmlCrypt.encrypt(stream.read, password))
      end

      stream
    ensure
      Relationship.clear_ids_cache
    end

    # Validate all parts of the package against xsd schema.
    # @return [Array] An array of all validation errors found.
    # @note This gem includes all schema from OfficeOpenXML-XMLSchema-Transitional.zip and OpenPackagingConventions-XMLSchema.zip
    #   as per ECMA-376, Third edition. opc schema require an internet connection to import remote schema from dublin core for dc,
    #   dcterms and xml namespaces. Those remote schema are included in this gem, and the original files have been altered to
    #   refer to the local versions.
    #
    #   If by chance you are able to create a package that does not validate it indicates that the internal
    #   validation is not robust enough and needs to be improved. Please report your errors to the gem author.
    # @see https://www.ecma-international.org/publications-and-standards/standards/ecma-376/
    # @example
    #  # The following will output any error messages found in serialization.
    #  p = Axlsx::Package.new
    #  # ... code to create sheets, charts, styles etc.
    #  p.validate.each { |error| puts error.message }
    def validate
      errors = []
      parts.each do |part|
        unless part[:schema].nil?
          errors.concat validate_single_doc(part[:schema], part[:doc].to_xml_string)
        end
      end
      errors
    end

    private

    # Writes the package parts to a zip archive.
    # @param [Zip::OutputStream, ZipCommand] zip
    # @return [Zip::OutputStream, ZipCommand]
    def write_parts(zip)
      p = parts
      p.each do |part|
        unless part[:doc].nil?
          zip.put_next_entry(zip_entry_for_part(part))
          part[:doc].to_xml_string(zip)
        end
        unless part[:path].nil?
          zip.put_next_entry(zip_entry_for_part(part))
          zip.write File.read(part[:path], mode: "rb")
        end
      end
      zip
    end

    # Generate a Entry for the given package part.
    # The important part here is to explicitly set the timestamp for the zip entry: Serializing axlsx packages
    # with identical contents should result in identical zip files – however, the timestamp of a zip entry
    # defaults to the time of serialization and therefore the zip file contents would be different every time
    # the package is serialized.
    #
    # Note: {Core#created} also defaults to the current time – so to generate identical axlsx packages you have
    # to set this explicitly, too (eg. with `Package.new(created_at: Time.local(2013, 1, 1))`).
    #
    # @param part A hash describing a part of this pacakge (see {#parts})
    # @return [Zip::Entry]
    def zip_entry_for_part(part)
      timestamp = Zip::DOSTime.at(@core.created.to_i)
      Zip::Entry.new("", part[:entry], "", "", 0, 0, Zip::Entry::DEFLATED, 0, timestamp)
    end

    # The parts of a package
    # @return [Array] An array of hashes that define the entry, document and schema for each part of the package.
    # @private
    def parts
      parts = [
        { entry: "xl/#{STYLES_PN}", doc: workbook.styles, schema: SML_XSD },
        { entry: CORE_PN, doc: @core, schema: CORE_XSD },
        { entry: APP_PN, doc: @app, schema: APP_XSD },
        { entry: WORKBOOK_RELS_PN, doc: workbook.relationships, schema: RELS_XSD },
        { entry: WORKBOOK_PN, doc: workbook, schema: SML_XSD }
      ]

      workbook.drawings.each do |drawing|
        parts << { entry: "xl/#{drawing.rels_pn}", doc: drawing.relationships, schema: RELS_XSD }
        parts << { entry: "xl/#{drawing.pn}", doc: drawing, schema: DRAWING_XSD }
      end

      workbook.tables.each do |table|
        parts << { entry: "xl/#{table.pn}", doc: table, schema: SML_XSD }
      end
      workbook.pivot_tables.each do |pivot_table|
        cache_definition = pivot_table.cache_definition
        parts << { entry: "xl/#{pivot_table.rels_pn}", doc: pivot_table.relationships, schema: RELS_XSD }
        parts << { entry: "xl/#{pivot_table.pn}", doc: pivot_table } # , :schema => SML_XSD}
        parts << { entry: "xl/#{cache_definition.pn}", doc: cache_definition } # , :schema => SML_XSD}
      end

      workbook.comments.each do |comment|
        unless comment.empty?
          parts << { entry: "xl/#{comment.pn}", doc: comment, schema: SML_XSD }
          parts << { entry: "xl/#{comment.vml_drawing.pn}", doc: comment.vml_drawing, schema: nil }
        end
      end

      workbook.charts.each do |chart|
        parts << { entry: "xl/#{chart.pn}", doc: chart, schema: DRAWING_XSD }
      end

      workbook.images.each do |image|
        parts << { entry: "xl/#{image.pn}", path: image.image_src } unless image.remote?
      end

      if use_shared_strings
        parts << { entry: "xl/#{SHARED_STRINGS_PN}", doc: workbook.shared_strings, schema: SML_XSD }
      end

      workbook.worksheets.each do |sheet|
        parts << { entry: "xl/#{sheet.rels_pn}", doc: sheet.relationships, schema: RELS_XSD }
        parts << { entry: "xl/#{sheet.pn}", doc: sheet, schema: SML_XSD }
      end

      # Sort parts for correct MIME detection
      [
        { entry: CONTENT_TYPES_PN, doc: content_types, schema: CONTENT_TYPES_XSD },
        { entry: RELS_PN, doc: relationships, schema: RELS_XSD },
        *parts.sort_by { |part| part[:entry] }.reverse
      ]
    end

    # Performs xsd validation for a signle document
    #
    # @param [String] schema path to the xsd schema to be used in validation.
    # @param [String] doc The xml text to be validated
    # @return [Array] An array of all validation errors encountered.
    # @private
    def validate_single_doc(schema, doc)
      schema = Nokogiri::XML::Schema(File.open(schema))
      doc = Nokogiri::XML(doc)
      errors = []
      schema.validate(doc).each do |error|
        errors << error
      end
      errors
    end

    # Appends override objects for drawings, charts, and sheets as they exist in your workbook to the default content types.
    # @return [ContentType]
    # @private
    def content_types
      c_types = base_content_types
      workbook.drawings.each do |drawing|
        c_types << Axlsx::Override.new(PartName: "/xl/#{drawing.pn}",
                                       ContentType: DRAWING_CT)
      end

      workbook.charts.each do |chart|
        c_types << Axlsx::Override.new(PartName: "/xl/#{chart.pn}",
                                       ContentType: CHART_CT)
      end

      workbook.tables.each do |table|
        c_types << Axlsx::Override.new(PartName: "/xl/#{table.pn}",
                                       ContentType: TABLE_CT)
      end

      workbook.pivot_tables.each do |pivot_table|
        c_types << Axlsx::Override.new(PartName: "/xl/#{pivot_table.pn}",
                                       ContentType: PIVOT_TABLE_CT)
        c_types << Axlsx::Override.new(PartName: "/xl/#{pivot_table.cache_definition.pn}",
                                       ContentType: PIVOT_TABLE_CACHE_DEFINITION_CT)
      end

      workbook.comments.each do |comment|
        unless comment.empty?
          c_types << Axlsx::Override.new(PartName: "/xl/#{comment.pn}",
                                         ContentType: COMMENT_CT)
        end
      end

      unless workbook.comments.empty?
        c_types << Axlsx::Default.new(Extension: "vml", ContentType: VML_DRAWING_CT)
      end

      workbook.worksheets.each do |sheet|
        c_types << Axlsx::Override.new(PartName: "/xl/#{sheet.pn}",
                                       ContentType: WORKSHEET_CT)
      end
      exts = workbook.images.map { |image| image.extname.downcase }
      exts.uniq.each do |ext|
        ct = if JPEG_EXS.include?(ext)
               JPEG_CT
             elsif ext == GIF_EX
               GIF_CT
             elsif ext == PNG_EX
               PNG_CT
             end
        c_types << Axlsx::Default.new(ContentType: ct, Extension: ext)
      end
      if use_shared_strings
        c_types << Axlsx::Override.new(PartName: "/xl/#{SHARED_STRINGS_PN}",
                                       ContentType: SHARED_STRINGS_CT)
      end
      c_types
    end

    # Creates the minimum content types for generating a valid xlsx document.
    # @return [ContentType]
    # @private
    def base_content_types
      c_types = ContentType.new
      c_types << Default.new(ContentType: RELS_CT, Extension: RELS_EX)
      c_types << Default.new(Extension: XML_EX, ContentType: XML_CT)
      c_types << Override.new(PartName: "/#{APP_PN}", ContentType: APP_CT)
      c_types << Override.new(PartName: "/#{CORE_PN}", ContentType: CORE_CT)
      c_types << Override.new(PartName: "/xl/#{STYLES_PN}", ContentType: STYLES_CT)
      c_types << Axlsx::Override.new(PartName: "/#{WORKBOOK_PN}", ContentType: WORKBOOK_CT)
      c_types.lock
      c_types
    end

    # Creates the relationships required for a valid xlsx document
    # @return [Relationships]
    # @private
    def relationships
      rels = Axlsx::Relationships.new
      rels << Relationship.new(self, WORKBOOK_R, WORKBOOK_PN)
      rels << Relationship.new(self, CORE_R, CORE_PN)
      rels << Relationship.new(self, APP_R, APP_PN)
      rels.lock
      rels
    end

    # Parse the arguments of `#serialize`
    # @return [Boolean, (String or nil), (String or nil)] Returns a 3-tuple where values are
    #   `confirm_valid`, `zip_command`, and `password`.
    # @private
    def parse_serialize_options(options, secondary_options)
      if secondary_options
        warn "[DEPRECATION] Axlsx::Package#serialize with 3 arguments is deprecated. " \
             "Use keyword args instead e.g., package.serialize(output, confirm_valid: false, zip_command: 'zip')"
      end
      if options.is_a?(Hash)
        options.merge!(secondary_options || {})
        invalid_keys = options.keys - [:confirm_valid, :zip_command, :password]
        if invalid_keys.any?
          raise ArgumentError, "Invalid keyword arguments: #{invalid_keys}"
        end

        [options.fetch(:confirm_valid, false), options.fetch(:zip_command, nil), options.fetch(:password, nil)]
      else
        warn "[DEPRECATION] Axlsx::Package#serialize with confirm_valid as a boolean is deprecated. " \
             "Use keyword args instead e.g., package.serialize(output, confirm_valid: false)"
        parse_serialize_options((secondary_options || {}).merge(confirm_valid: options), nil)
      end
    end

    def ensure_ooxml_crypt!
      return if defined?(OoxmlCrypt)

      raise 'Axlsx encryption requires ooxml_crypt gem'
    end
  end
end
