module Koti
  READ_LIMIT = 1024*1024
  class System
    BIN_UNAME = "uname"
    BIN_GIT   = "git"

    def self.uname(arg)
      out = System.run(BIN_UNAME, arg)
      out[:output] as String
    end

    def self.git(*args)
      out = System.run(BIN_GIT, *args)
      out[:exit_code] as Int32
    end

    def self.run(bin, *args)
      Out.put "running '#{bin} #{args.join(" ")}'", 5
      output = ""
      stderr = stdout = exit_code = nil
      Process.run(bin, args) do |process|
        stdout = process.output.gets(READ_LIMIT)
        stderr = process.error.gets(READ_LIMIT)
        Out.put "stderr: ", 10
        Out.put stderr, 10, :fail
        Out.put "", 10
        Out.put "stdout: ", 10
        Out.put stdout, 10, :ok
        Out.put "", 10
        exit_code = process.wait.exit_code
        if exit_code == 0 && stdout
          output = (stdout as String)
        else
          output = (stderr as String) if stderr
        end
        output = output.chop
      end
      {
        stdout: stdout,
        stderr: stderr,
        output: output,
        exit_code: exit_code,
      }
    end
  end
end
