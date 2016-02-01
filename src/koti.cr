require "yaml"
require "colorize"
require "option_parser"
require "./koti/config.cr"
require "./koti/environment.cr"
require "./koti/repository.cr"
require "./koti/outputter.cr"
require "./koti/system.cr"
require "./koti/theme.cr"
require "./koti/app.cr"

module Koti
  class Koti
    def initialize(verbosity = 3)
      Out.verbosity = verbosity
      if File.exists? MAIN_CONFIG_FILE
        @installed = true
        @config = KotiConfig.from_yaml(File.read(MAIN_CONFIG_FILE))
      else
        @config = KotiConfig.from_yaml(MOCK_YAML_CONFIG)
      end
      env = Environment.new
      @repo = Repository.new(@config)
      @app = App.new(env.os, env.host)
    end

    def install(url="https://github.com/ytti/dot")
      Out.str "Installing from #{url}... ", 2
      @repo.update url, MAIN
      @config = KotiConfig.from_yaml(File.read(MAIN_CONFIG_FILE))
      @repo = Repository.new(@config)
      Out.put "done", 2, :ok
      update
    end

    def update
      build collapsed_app_configs
    end

    def installed?
      @installed
    end

    private def  build(apps)
      apps.each do |app, cfg|
        app_dir = File.join ROOT, "composite", app
        Dir.mkdir_p app_dir, DIR_MODE
        cfg.files.each do |_, file|
          composite_file = File.join app_dir, file.source
          config = file.config
          target = file.target
          File.write composite_file, config, FILE_MODE
          symlink(composite_file, target)
        end
        cfg.links.each do |real, symbolic|
          symlink(real, symbolic)
        end
      end
    end

    private def symlink(real, link)
      link_full = File.expand_path(link)
      link_file = File.basename(link_full)
      link_dir  = File.dirname(link_full)
      Dir.mkdir_p link_dir, DIR_MODE
      if File.exists?(link_full) && !File.symlink?(link_full)
        Out.err "Unable to link #{real} to #{link_full}, file exists", 2
        return
      elsif File.symlink?(link_full)
        # alas no File.readlink, so let's just assume it's unwanted...
        File.delete(link_full)
      end
      Out.put "Linking #{real} to #{link_full}", 3
      File.symlink(real, link_full)
    end

    private def collapsed_app_configs
      apps = {} of String => App::Collapsed
      get_app_configs.each do |repo, repo_apps|
        repo_apps.each do |app, config|
          apps[app] = App::Collapsed.new unless apps.has_key? app
          config.files.each do |file|
            Out.str "Building #{app} config #{file.source} from #{repo}... ", 3
            apps[app].merge(file)
            Out.put "done", 3, :ok
          end
          apps[app].links.merge! config.links
        end
      end
      apps
    end

    private def get_app_configs
      @repo.update_all
      repos = {} of String => Hash(String, App::Config)
      @repo.names.each do |repo|
        repos[repo] = {} of String => App::Config
        @repo.apps(repo).each do |app|
          repos[repo][app] = @app.build(app, repo)
        end
      end
      repos
    end
  end
end
