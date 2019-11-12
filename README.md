# Avatax

Avatax by Avalara provides a centralized service for tracking sales tax bills.
This plugin integrates that service into the Workarea platform. Instead of using
the Workarea platform's included sales tax caclulation system, it uses Avatax to
calculate sales tax. After an order is placed, that order's sales tax bill is
transmitted to Avatax. Users may choose to commit (save them so that they are
reflected in tax liability) posted documents either via Workarea platform, or
via their own order management system.

## Features

### Out of the Box

* Full reporting feature with summarized and detailed reports
* Constant real time updates with the latest rules and regulations for accuracy

## Requirements

* Avalara Avatax account (These values can be found in your Avalara administration console upon Registration)
* Account Number
* License Key
* API URL
* Shipping Item Code or Tax Code

## Installation and Configuration

### 1) Add the Application gem to your gemfile in host application

```ruby
  gem 'workarea-avatax', '~> <version>'
```

### 2) Add Avatax Secrets

```ruby
  avatax:
    username: AVATAX_USERNAME
    password: AVATAX_PASSWORD
```

Optionally set the endpoint to sandbox for testing.

### 3) Configure the avatax plugin with the merchant's distribution center inside the host app's `config/initializers/workarea.rb` file

```ruby
  Workarea::Avatax.configure do |config|
    config.dist_center = {
      Line1: '1234 Your St',
      Line2: '',
      City: 'YourCity',
      Region: 'Your State',
      Country: 'US',
      PostalCode: '123456'
    }
  end
```
