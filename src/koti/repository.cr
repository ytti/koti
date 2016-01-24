module Koti
  class Repository
    getter :names
    def initialize(config)
      @config = config
      @names = get_repo_names
    end

    def update_all
      @config.repository.each do |name, url|
        Out.str "Updating repo #{name}... ", 2
        style = update url, File.join(REPO, name)
        Out.put "#{style.to_s}", 2, style
      end
    end

    def update(url, directory)
      if Dir.exists? directory
        git_dir = File.join directory, ".git"
        err_level = System.git "--git-dir=#{git_dir}", "--work-tree=#{directory}", "pull"
      else
        err_level = System.git "clone", url, directory
      end
      err_level > 0 ? :fail : :ok
    end

    def apps(repo)
      dir = File.join REPO, repo, "app"
      app_names = [] of String
      return app_names unless Dir.exists? dir
      Dir.foreach(dir) do |dir|
        next if dir[0] == '.'
        app_names << dir
      end
      app_names
    end

    private def get_repo_names
      repos = @config.repository.keys
      unless repos.includes? "main"
        Out.err "'Main' repository is not defined"
        exit 102
      end
      repos
    end
  end
end
