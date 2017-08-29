# Fluent::Plugin::BelatedRecordFilter

[![Build Status](https://travis-ci.org/reizist/fluent-plugin-belated-record-filter.svg?branch=master)](https://travis-ci.org/reizist/fluent-plugin-belated-record-filter)

A Filter plugin of fluentd for filtering older records than newest one.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-belated-record-filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-belated-record-filter

## Usage

### BelatedRecordFilter

Add belated_record filter.

```
<filter **>
  @type belated_record
  <extract>
    time_key start_at
    time_type string
    time_format %Y-%m-%dT%H:%M:%S %z
    keep_time_key true
  </extract>
</filter>
```

In the case of incoming this records:

```
{"message": "hogehoge", "start_at":"2017-08-28T03:45:03+00:00"}
{"message": "fugafuga", "start_at":"2017-08-28T03:45:05+00:00"}
{"message": "piyopiyo", "start_at":"2017-08-28T03:45:02+00:00"}
```

Then output becomes as belows:

```
{"message": "hogehoge", "start_at":"2017-08-28T03:45:03+00:00"}
{"message": "fugafuga", "start_at":"2017-08-28T03:45:05+00:00"}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reizist/fluent-plugin-belated-record-filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

