module Koti
  class Theme
    getter ok, fail
    def initialize
    end

    def style(theme)
      case theme
      when :ok
        :green
      when :fail
        :red
      else
        :nil
      end
    end
  end
end
