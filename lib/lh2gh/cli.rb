require 'thor'
require 'lh2gh'
require 'uri'

module Lh2gh
  class CLI < Thor
    include Octopi

    desc 'migrate', 'Migrate tickets from Lighthouse to Github Issues'
    method_option :lh_account, :type => :string, :required => true
    method_option :lh_token, :type => :string, :required => true
    method_option :gh_repository, :type => :string, :required => true, :banner => "rails/rails"
    def migrate
      Lighthouse.account = options[:lh_account]
      Lighthouse.token = options[:lh_token]
      project = Lighthouse::Project.find :first
      tickets = Lighthouse::Ticket.find :all, :params => { :project_id => project.id }
      repo_user, repo_name = options[:gh_repository].split '/'

      authenticated do
        repo = Octopi::Repository.find :name => repo_name, :user => repo_user
        tickets.each do |ticket|
          new_body = "Imported from lighthouse. Original ticket at: #{ticket.url}. Created by #{ticket.creator_name} - #{ticket.created_at}\n\n#{ticket.original_body}"
          params = {:title => ticket.title, :body => new_body}

          issue = Octopi::Issue.open :repo => repo, :params => params
          ticket.tags.each { |tag| issue.add_label URI.escape(tag) }
          issue.add_label ticket.state
          issue.close! if ticket.closed
          if ticket.respond_to? :versions
            comments = ticket.versions
            comments.shift
            comments.each do |comment|
              next if comment.body.blank?
              issue.comment "Imported from Lighthouse. Comment by #{comment.user_name} - #{comment.created_at}\n\n#{comment.body}"
            end
          end
        end
      end
    end

    desc 'version', 'Print version info for Lighthouse 2 Github'
    map %w(-v --version) => :version
    def version
      puts "Lighthouse 2 Github v#{Lh2gh::VERSION}"
    end

  end
end
