require 'thor'

module Lh2gh
  class CLI < Thor

    desc 'version', 'Print version info for Lighthouse 2 Github'
    map %w(-v --version) => :version
    def version
      puts "Lighthouse 2 Github v#{Lh2gh::VERSION}"
    end

  end
end
