require 'thor'
require 'lh2gh'
require 'uri'

module Lh2gh
  class CLI < Thor
    include Octopi

    desc 'migrate', 'Migrate tickets from Lighthouse to Github Issues'
    method_option :lh_account, :type => :string, :required => true, :banner=>"rails", :desc=>"The Lighthouse account name."
    method_option :lh_token, :type => :string, :required => true, :banner=>"4ag5hsa...etc", :desc=>"A Lighthouse API token that has READ access to the projects you want to migrate from."
    method_option :gh_repository, :type => :string, :required => true, :banner => "rails/rails"
    method_option :project_id, :type=>:numeric, :required=>false, :banner=>'12345', :desc=>"The Lighthouse project ID to migrate from (defaults to :first)"
    method_option :page, :type=>:numeric, :required=>false, :banner=>'5', :default=>1, :desc=>"Which 'page' of tickets to start from (Each page is ~30 tickets)."
    def migrate
      Lighthouse.account = options[:lh_account]
      Lighthouse.token = options[:lh_token]
      project_id = options[:project_id]
      project = Lighthouse::Project.find (project_id ? project_id : :first)
      repo_user, repo_name = options[:gh_repository].split '/'
      
      puts "Migrating tickets from Lighthouse Project #{project.name}."
      authenticated do
        repo = Octopi::Repository.find :name => repo_name, :user => repo_user
        page = options[:page]
        while(true) do
          tickets = get_page_of_tickets(project, page)
          break if tickets.size == 0
          puts "Entering page ##{page} of tickets from LH."
          tickets.each do |ticket|
            convert_lh_ticket_to_gh(ticket, repo)
          end
          page += 1
        end
      end      
    end

    desc 'version', 'Print version info for Lighthouse 2 Github'
    map %w(-v --version) => :version
    def version
      puts "Lighthouse 2 Github v#{Lh2gh::VERSION}"
    end

    private
    
    def convert_lh_ticket_to_gh(ticket, repo)
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
      puts "Converted LH ##{ticket.id} into Github issue ##{issue.number}."      
    end
    
    def get_page_of_tickets(project, page_number)
      tickets = Lighthouse::Ticket.find :all, :params => { :project_id => project.id, :page=>page_number }
    end
    
  end
end
