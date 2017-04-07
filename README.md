Sisito
================

It is [sisimai](http://libsisimai.org/) collected data frontend.

## Screenshot

![](https://cdn.pbrd.co/images/PBJu7ECzS.png) &nbsp; ![](https://cdn.pbrd.co/images/PBJO0Ki4E.png)
![](https://cdn.pbrd.co/images/PBK20BtTS.png) &nbsp; ![](https://cdn.pbrd.co/images/59YqgEhyv.png)
![](https://cdn.pbrd.co/images/PBKp4yg4A.png)

## Installation

```sh
bundle install
vi confing/database.yml
bundle exec db:create db:migrate
bundle exec rails s
```

## Recommended System Requirements

* Ruby 2.3
* MySQL 5.6/5.7


## Bounced Mail Collect Script Example

```ruby
#!/usr/bin/env ruby
require 'fileutils'
require 'sisimai'
require 'mysql2'
require 'tmpdir'

COLUMNS = %w(
  timestamp
  lhost
  rhost
  alias
  listid
  reason
  action
  subject
  messageid
  smtpagent
  softbounce
  smtpcommand
  destination
  senderdomain
  feedbacktype
  diagnosticcode
  deliverystatus
  timezoneoffset
  addresser
  recipient
)

MAIL_DIR = '/home/scott/Maildir/new'

def process(path, **options)
  Dir.mktmpdir do |tmpdir|
    FileUtils.mv(Dir["#{path}/*"], tmpdir)
    v = Sisimai.make(tmpdir, **options) || []
    v.each {|e| yield(e) }
  end
end

def insert(mysql, data)
  values = data.to_hash.values_at(*COLUMNS)
  addresseralias = data.addresser.alias
  addresseralias = data.addresser if addresseralias.empty?
  values << addresseralias
  columns = (COLUMNS + ['addresseralias', 'digest', 'created_at', 'updated_at']).join(?,)
  timestamp = values.shift
  values = (["FROM_UNIXTIME(#{timestamp})"] + values.map(&:inspect) + ['SHA1(recipient)', 'NOW()', 'NOW()']).join(?,)
  sql = "INSERT INTO bounce_mails (#{columns}) VALUES (#{values})"
  mysql.query(sql)
end

mysql = Mysql2::Client.new(host: 'db-server', username: 'root', database: 'sisito')

process(MAIL_DIR) do |data|
  insert(mysql, data)
end
```

## List Blacklisted Recipients SQL Example

```sql
SELECT
  recipient
FROM
  bounce_mails bm
  LEFT JOIN whitelist_mails wm
    ON bm.recipient = wm.recipient
   AND bm.senderdomain = wm.senderdomain
WHERE
  bm.senderdomain = 'example.com'
  AND wm.id IS NULL
  /*
  AND bm.softbounce = 1
  AND bm.reason IN ('filtered')
  */
```

## Related Links

* http://libsisimai.org
* https://github.com/winebarrel/sisito-api
