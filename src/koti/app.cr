require "yaml"
module Koti
  class App

    def initialize(os, host)
      @os   = os
      @host = host
    end

    def build(app, repo)
      dir        = File.join REPO, repo, "app", app
      config     = Config.new
      app_config = load_config dir
      app_config.files.keys.each do |file|
        subfile = file
        subfile = nil if file == "main"
        config.files << CfgFile.new(file, app_config.files[file], build_file(dir, subfile))
      end
      config.links = resolve_links(dir, app_config)
      config
    end

    private def resolve_links(app_dir, config)
      links = {} of String => String
      config.links.each do |real, symbolic|
        dir = File.join(app_dir, real)
        links[File.join(dir, "main")] = symbolic
        links.merge! resolve_links_conditional(File.join(dir, "os", @os),     symbolic)
        links.merge! resolve_links_conditional(File.join(dir, "host", @host), symbolic)
        #puts "real #{real} => #{symbolic}"
      end
      links
    end

    private def resolve_links_conditional(dir_real, dir_symbolic)
      links = {} of String => String
      return links unless Dir.exists? dir_real
      Dir.foreach(dir_real) do |file|
        next if file[0] == '.'
        links[File.join(dir_real, file)] = File.join(dir_symbolic, file)
      end
      links
    end

    private def build_file(dir, subfile=nil)
      if subfile
        dir = File.join(dir, subfile)
      end
      os   = concat_files(File.join(dir, "os", @os))
      host = concat_files File.join dir, "host", @host
      main = concat_files File.join dir, "main"
      os + host + main
    end

    private def load_config(dir)
      file = File.join(dir, "config.yaml")
      yaml = File.read(file)
      cfg  = nil
      begin
        AppConfig.from_yaml(yaml)
      rescue error : YAML::ParseException
        Out.err "Unable to parse YAML, #{file} - #{error.message}"
        exit 42
      end
    end

    private def concat_files(dir)
      cfg = ""
      return cfg unless Dir.exists?(dir)
      Dir.foreach(dir) do |file|
        next if file[0] == '.'
        cfg += File.read(File.join dir, file)
      end
      cfg
    end

    class Config
      property :files, :links
      def initialize()
        @files = [] of CfgFile
        @links = {} of String => String
      end
    end

    class CfgFile
      property :source, :target, :config
      def initialize(source, target, config)
        @source = source
        @target = target
        @config = config
      end
    end

    class Collapsed
      property files, links
      def initialize()
        @files = {} of String => CfgFile
        @links = {} of String => String
      end
      def merge(cfgfile)
        if @files.key? cfgfile.source
          @files[cfgfile.source].source  = cfgfile.source
          @files[cfgfile.source].target  = cfgfile.target
          @files[cfgfile.source].config += cfgfile.config
        else
          @files[cfgfile.source] = CfgFile.new(cfgfile.source, cfgfile.target, cfgfile.config)
        end
      end
    end
  end

  class AppConfig
    YAML.mapping({
      files: Hash(String, String),
      links: Hash(String, String),
    })
  end
end
