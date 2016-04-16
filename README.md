Prelaunchr
==========

Originally open sourced over on our [engineering blog](http://engineering.harrys.com/2014/07/21/dont-launch-crickets.html),
and discussed in great detail over at [Tim Ferriss' Blog](http://fourhourworkweek.com/2014/07/21/harrys-prelaunchr-email),
Prelaunchr is a skeleton Rails application for quickly starting a viral
prelaunch campaign for new companies or products. The campaign is conducive to
social sharing and has prize levels based on the number of people each person
refers. By default, we've included our original HTML/CSS for both the site and
email to give you a better idea of how this looked when actually running.

## Mechanics

Prelaunchr has a main mechanic from which everything else is derived: Every
`User` is given a unique `referral_code` which is how the application knows who
referred a signing up user. Based on the amount of referrals a `User` has
brought to the site, they are put into a different "prize group". The groups,
amounts, and prizes are completely up to you to set.

## IP Blocking

By default, we block more than 2 sign-ups from the same IP address. This was
simplistic, but was good enough for us during our campaign. If you want
something more substantial take a look at [Rack::Attack](https://github.com/kickstarter/rack-attack)


## Developer Setup

Get Ruby 2.3.0 (rbenv), bundle and install:

```no-highlight
brew update && brew upgrade ruby-build && rbenv install 2.3.0
```

Clone the repo and enter the folder (commands not shown).

Install Bundler, Foreman and Mailcatcher then Bundle:

```no-highlight
gem install bundler foreman mailcatcher
bundle
```

Copy the local `database.yml` file sample and `.env.sample`:

```no-highlight
cp config/database.yml.sample config/database.yml
cp .env.sample .env
```

Update your newly created .env file with the needed configuration
DEFAULT\_MAILER\_HOST: sets the action mailer default host as seen in
config/environment/<environment>.rb. You will minimally need this in production.
SECRET\_KEY\_BASE: sets a secret key to be used by config/initializers/devise.rb

Setup your local database:

```no-highlight
bundle exec rake db:create
bundle exec rake db:migrate
```

Start local server and mail worker:

```no-highlight
foreman start -f Procfile.dev
```

View your website at the port default `http://localhost:5000/`.
View sent mails at `http://localhost:1080/`.

### To create an admin account

In Rails console, run this command. Be careful to not use the example admin user
for security reasons. Password confirmation should match password.

`AdminUser.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'passwordconfirmaiton')`

You can run this locally in a Rails console for development testing.

If you are deployed to Heroku, you would run it there.

## Teardown

When your prelaunch campaign comes to an end we've included a helpful `rake`
task to help you compile the list of winners into CSV's containing the email
addresses and the amount of referrals the user had.

* Run `bundle exec rake prelaunchr:create_winner_csvs` and the app will export
CSV's in `/lib/assets` corresponding to each prize group.

## Configuration

* Set the different prize levels on the `User::REFERRAL_STEPS` constant inside
`/app/models/user.rb`
* The `config.ended` setting in `/config/application.rb` decides whether the
prelaunch campaign has ended or not (e.g. Active/Inactive). We've included this
option so you can quickly close the application and direct users to your newly
launched site.

## License

The code, documentation, non-branded copy and configuration are released under
the MIT license. Any branded assets are included only to illustrate and inspire.

Please change the artwork to use your own brand! Harry's does not give
you permission to use our brand or trademarks in your own marketing.
