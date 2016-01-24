module Koti
  class Outputter
    property verbosity
    property theme
    def initialize(verbosity=100, theme=Theme.new)
      @verbosity = verbosity
      @theme     = theme
    end
    def str(string, verbosity=1, style=nil)
      return unless @verbosity >= verbosity
      print _put(string, verbosity, style)
    end
    def put(string, verbosity=1, style=nil)
      return unless @verbosity >= verbosity
      puts _put(string, verbosity, style)
    end
    def err(string, verbosity=1)
      return unless @verbosity >= verbosity
      #STDERR.puts _put(string, verbosity, :fail)
      puts _put(string, verbosity, :fail)
    end
    def _put(string, verbosity, style)
      if style
        string = string.colorize(@theme.style(style))
      end
      string
    end
  end
  Out = Outputter.new
end
