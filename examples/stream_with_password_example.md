## Description

You may return a stream for a encrypted, password-protected package.
Requires `ooxml_crypt` gem to be installed.

## Code

```ruby
require 'ooxml_crypt'
require 'axlsx'

p = Axlsx::Package.new
wb = p.workbook

wb.add_worksheet(name: 'Basic Worksheet') do |sheet|
  sheet.add_row ['First', 'Second', 'Third']
  sheet.add_row [1, 2, 3]
end

stream = p.to_stream(password: 'abc123')
File.write('encrypted.xlsx', stream.read)

# To decrypt the file
OoxmlCrypt.decrypt_file('encrypted.xlsx', 'abc123', 'decrypted.xlsx')
```

## Output

The output is equivalent to using `Axlsx::Package#serialize` with password.
