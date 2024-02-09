## Description

You may encrypt your package and protect it with a password.
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

p.serialize('encrypted.xlsx', password: 'abc123')

# To decrypt the file
OoxmlCrypt.decrypt_file('encrypted.xlsx', 'abc123', 'decrypted.xlsx')
```

## Output

The output file will be encrypted and password-protected.
