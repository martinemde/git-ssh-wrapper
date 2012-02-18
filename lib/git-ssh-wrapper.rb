require 'tempfile'
require 'pathname'

class GitSSHWrapper

  class PrivateKeyRequired < ArgumentError
    def initialize
      super "You must specify either :private_key_path (path to ssh private key) or :private_key (string of ssh private key)."
    end
  end

  SAFE_MODE = 0600
  EXEC_MODE = 0700


  def self.tempfile(content, mode=SAFE_MODE)
    file = Tempfile.new("git-ssh-wrapper")
    file << content
    file.chmod(mode)
    file.flush
    file.close
    file
  end

  def self.with_wrapper(options)
    wrapper = new(options)
    yield wrapper
  ensure
    wrapper.unlink
  end

  attr_reader :path

  def initialize(options)
    if options[:private_key_path].to_s.empty? && options[:private_key].to_s.empty?
      raise PrivateKeyRequired
    end

    log_level  = (options[:log_level] || 'INFO').upcase
    @tempfiles = []
    key_path   = options[:private_key_path] || tempfile(options[:private_key])
    @path      = script(key_path, log_level)
  end

  def pathname
    Pathname.new(path)
  end

  def cmd_prefix
    "GIT_SSH='#{path}'"
  end
  alias git_ssh cmd_prefix

  def set_env
    ENV['GIT_SSH'] = path
  end

  def unlink
    @tempfiles.each { |file| file.unlink }.clear
  end

  private

  def script(private_key_path, log_level)
    tempfile(<<-SCRIPT, EXEC_MODE)
#!/bin/sh
unset SSH_AUTH_SOCK
ssh -o 'CheckHostIP no' -o 'StrictHostKeyChecking no' -o 'PasswordAuthentication no' -o 'LogLevel #{log_level}' -o 'IdentityFile #{private_key_path}' -o 'IdentitiesOnly yes' -o 'UserKnownHostsFile /dev/null' $*
    SCRIPT
  end

  def tempfile(content, mode=SAFE_MODE)
    file = self.class.tempfile(content, mode)
    @tempfiles << file
    file.path
  end
end
