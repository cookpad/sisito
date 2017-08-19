Sisito
================

It is [sisimai](http://libsisimai.org/) collected data frontend.

## Screenshot

![](https://cdn.pbrd.co/images/PBJu7ECzS.png) &nbsp; ![](https://cdn.pbrd.co/images/PBJO0Ki4E.png)
![](https://cdn.pbrd.co/images/PBK20BtTS.png) &nbsp; ![](https://cdn.pbrd.co/images/59YqgEhyv.png)
![](https://cdn.pbrd.co/images/PBKp4yg4A.png)

## Installation

```sh
git clone https://github.com/winebarrel/sisito.git
cd sisito
bundle install
vi confing/database.yml
bundle exec rails db:create db:migrate
bundle exec rails s
```

### Using docker

```
git clone https://github.com/winebarrel/sisito.git
cd sisito
docker-compose build
docker-compose up
# console: http://localhost:3000
# api: `curl localhost:8080/blacklist` (see https://github.com/winebarrel/sisito-api#api)
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
  values << addresseralias.to_s
  columns = (COLUMNS + ['addresseralias', 'digest', 'created_at', 'updated_at']).join(?,)
  timestamp = values.shift
  values = (["FROM_UNIXTIME(#{timestamp})"] + values.map(&:inspect) + ['SHA1(recipient)', 'NOW()', 'NOW()']).join(?,)
  sql = "INSERT INTO bounce_mails (#{columns}) VALUES (#{values})"
  mysql.query(sql)
end

# sql:
#   INSERT INTO bounce_mails (
#     timestamp,
#     lhost,
#     rhost,
#     alias,
#     listid,
#     reason,
#     action,
#     subject,
#     messageid,
#     smtpagent,
#     softbounce,
#     smtpcommand,
#     destination,
#     senderdomain,
#     feedbacktype,
#     diagnosticcode,
#     deliverystatus,
#     timezoneoffset,
#     addresser,
#     recipient,
#     addresseralias,
#     digest,
#     created_at,
#     updated_at
#   ) VALUES (
#     /* timestamp    */  FROM_UNIXTIME(1503152383),
#     /* lhost        */  "43b36f28aa95",
#     /* rhost        */  "",
#     /* alias        */  "user-1503152383@a.b.c",
#     /* listid       */  "",
#     /* reason       */  "hostunknown",
#     /* action       */  "failed",
#     /* subject      */  "subject-1503152383",
#     /* messageid    */  "20170819141943.A58CC35A@43b36f28aa95",
#     /* smtpagent    */  "MTA::Postfix",
#     /* softbounce   */  0,
#     /* smtpcommand  */  "",
#     /* destination  */  "a.b.c",
#     /* senderdomain */  "43b36f28aa95",
#     /* feedbacktype */  "",
#     /* diagnosticco */  "Host or domain name not found. Name service error for name=a.b.c type=AAAA: Host not found",
#     /* deliverystat */  "5.4.4",
#     /* timezoneoffs */  "+0900",
#     /* addresser    */  "root@43b36f28aa95",
#     /* recipient    */  "user-1503152383@a.b.c",
#     /* addresserali */  "root@43b36f28aa95",
#     /* digest       */  SHA1(recipient),
#     /* created_at   */  NOW(),
#     /* updated_at   */  NOW()
#   )

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

## Monitoring

```
$ curl -s localhost:3000/status | jq .
{
  "start_time": "2017-08-19T22:36:08.887+09:00",
  "interval": 60,
  "count": {
    "all": 7,
    "reason": {
      "hostunknown": 7
    },
    "senderdomain": {
      "43b36f28aa95.cookpad.local": 7
    },
    "destination": {
      "a.b.c": 7
    }
  }
}
```

## Using Local Timezone

Please fix [config/application.rb](https://github.com/winebarrel/sisito/blob/master/config/application.rb) as follows:

```ruby
module Sisito
  class Application < Rails::Application
    ...
    config.active_record.default_timezone = :local
    config.time_zone = "Tokyo"
    ...
```

## Customize Sisito

see [config/sisito.yml](https://github.com/winebarrel/sisito/blob/master/config/sisito.yml)

## Related Links

* http://libsisimai.org
* https://github.com/winebarrel/sisito-api
