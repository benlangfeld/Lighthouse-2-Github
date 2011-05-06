# Lighthouse to Github Migration Tool

This is a command line tool for migrating Lighthouse project into the Github issues tracker.

## Installing

You need to build this gem yourself. Here's how:

``` shell
$ git clone https://github.com/benlangfeld/Lighthouse-2-Github.git
$ cd Lighthouse-2-Github
$ rake build && gem install pkg/gem build pkg/lh2gh-0.0.1.gem 

## Usage

```
$ lh2gh migrate --gh-repository=your_repo/your_project --lh-account=your_lh_account --lh-token=56Ads...123

```

This will pull all tickets from the first project in your LH account. Ensure your API token has access to the project.

## Features

* Pulls all LH tickets (open or closed) from a single project
* Specify the project_id to pull from (default to the 'first' project)
* Specify which 'page' of tickets to pull (defaults to the first page, which will be 30 or so tickets)