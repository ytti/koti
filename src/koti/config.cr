require "yaml"
module Koti
  class KotiConfig
    YAML.mapping({
      repository: Hash(String, String)
    })
  end
  ROOT = File.join ENV["HOME"], ".koti"
  REPO = File.join ROOT, "repository"
  MAIN = File.join REPO, "main"
  MAIN_CONFIG_FILE = File.join MAIN, "koti.yaml"
  DIR_MODE  = 0o700
  FILE_MODE = 0o600
  MOCK_YAML_CONFIG = <<-EOF
---
  repository:
    main: moi
  EOF
end
