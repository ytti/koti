require "../koti.cr"

module Koti
  class CLI
    VERBOSE = 3
    def initialize
      install_repo, verbose = parse_opts
      @koti = Koti.new(verbose as Int32)
      if install_repo
        @koti.install (install_repo as String)
      elsif @koti.installed?
        @koti.update
      else
        Out.err "koti not installed, try 'koti --install git@github.com:user/repo'"
      end
    end

    private def parse_opts
      install_repo = nil
      verbose      = VERBOSE
      OptionParser.parse! do |opt|
        opt.banner = "Usage: koti [arguments]"

        opt.on "-v LEVEL", "--verbose=LEVEL", "set verbosity level to (numeric) LEVEL, default to #{VERBOSE}" do |arg|
          verbose = arg.to_i as Int32
        end

        opt.on "-i MAIN_REPO", "--install=MAIN_REPO", "installs koti using MAIN_REPO as main repository" do |arg|
          install_repo = arg
        end

        opt.on "-h", "--help", "Display this help" { puts opt }
      end
      [install_repo, verbose]
    end
  end
end
