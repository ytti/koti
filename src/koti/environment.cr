module Koti
  class Environment
    def initialize
    end

    def host
      System.uname "-n"
    end

    def os
      case kernel
      when "Linux"
        "linux"
      when "Darwin"
        "osx"
      else
        "unknown"
      end
    end

    def kernel
      System.uname "-s"
    end

  end
end
