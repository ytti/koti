require "yaml"
module Koti
  class App

    def initialize(os, host)
      @os   = os
      @host = host
    end

    def build(app, repo)
      dir  = File.join REPO, repo, "app", app
      config = load_config dir
      files = {} of String => Hash(String, String)
      config.files.keys.each do |file|
        subfile = file
        subfile = nil if file == "main"
        files[file] = {
          "target" => config.files[file],
          "config" => build_file(dir, subfile),
        }
      end
      files
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
      yaml = File.read(File.join(dir, "config.yaml"))
      AppConfig.from_yaml(yaml)
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

  end
  class AppConfig
    YAML.mapping({
      files: Hash(String, String),
    })
  end
end
