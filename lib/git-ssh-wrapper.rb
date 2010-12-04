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

  SSH_CONFIG = <<-CONFIG
Host *
PasswordAuthentication no
StrictHostKeyChecking no
RSAAuthentication yes
ConnectTimeout 5
IdentityFile %s
CheckHostIP no
  CONFIG

  SCRIPT = <<-SCRIPT
#!/bin/bash
unset SSH_AUTH_SOCK
ssh -F %s $*
  SCRIPT

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

    @tempfiles  = []
    @key_path   = options[:private_key_path] || tempfile(options[:private_key])
    @ssh_config = ssh_config(@key_path)
    @path       = script(@ssh_config)
  end

  def pathname
    Pathname.new(path)
  end

  def git_ssh
    "GIT_SSH='#{path}'"
  end

  def set_env
    ENV['GIT_SSH'] = path
  end

  def unlink
    @tempfiles.each { |file| file.unlink }.clear
  end

  private

  def script(config_path)
    tempfile(SCRIPT % config_path, EXEC_MODE)
  end

  def ssh_config(private_key_path)
    tempfile(SSH_CONFIG % private_key_path)
  end

  def tempfile(content, mode=SAFE_MODE)
    file = self.class.tempfile(content, mode)
    @tempfiles << file
    file.path
  end
end
