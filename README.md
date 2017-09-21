# Fluent::Plugin::ComparisonFilter

[![Build Status](https://travis-ci.org/reizist/fluent-plugin-comparison-filter.svg?branch=master)](https://travis-ci.org/reizist/fluent-plugin-comparison-filter)

A Filter plugin of fluentd for filtering by comparing records between newest one and the others.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-comparison-filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-comparison-filter

## Configuration

### Comparison section
| name            | type          | required?    | default | description                                       |
| :-------------  | :------------ | :----------- | :-------| :-----------------------                          |
| column_key      | string        | yes          | nil     | the column for using comparison
| column_key_type | enum          | yes          | time    | time or numeric                   
| time_type       | enum          | no           | float   | type of time type, float or string or unixtime
| time_format     | string        | no           | nil     | 
| localtime       | bool          | no           | true    | UTC if :localtime is false and :timezone is nil                     
| utc             | bool          | no           | false   |
| timezone        | string        | no           | nli     |

## Usage

### ComparisonFilter

Add comparison filter.

```
<filter **>
  @type comparison
  <comparison>
    column_key start_at
    columm_key_type time
    time_type string
    time_format %Y-%m-%dT%H:%M:%S %z
  </comparison>
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

In the other case like this,

```
<filter **>
  @type comparison
  <comparison>
    column_key id 
    columm_key_type numeric
  </comparison>
</filter>
```

input:

```
{"message": "hogehoge", "id": 1 }
{"message": "fugafuga", "id": 5 }
{"message": "piyopiyo", "id": 3 }
{"message": "mogemoge", "id": 8 }
```

output:

```
{"message": "hogehoge", "id": 1 }
{"message": "fugafuga", "id": 5 }
{"message": "mogemoge", "id": 8 }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reizist/fluent-plugin-comparison-filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

