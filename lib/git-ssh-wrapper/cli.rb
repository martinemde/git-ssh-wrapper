require 'git-ssh-wrapper'
require 'git-ssh-wrapper/version'

class GitSSHWrapper::CLI
  # Calls any command with GIT_SSH set.
  #
  # Examples of argv:
  #   [key_path, git, fetch, origin]
  #   [key_path, some/script, that, calls, git]
  def self.wrapper(args=ARGV)
    new(*args).call
  end

  # Inserts git into the command if it's not there.
  # The command must be a git command.
  #
  # Examples of argv:
  #   [key_path, fetch, origin]
  #   [key_path, git, fetch, origin]
  def self.git_ssh(args=ARGV)
    key, *command = *args
    command.unshift('git') unless command.first == 'git'
    new(key, *command).call
  end

  attr_reader :key, :command

  def initialize(*args)
    @key, *@command = *args
  end

  def call
    if %w[--help -h help].include?(key)
      print_help
    end

    if %w[--version -v].include?(key)
      print_version
    end

    if key.nil? || command.empty?
      error
    elsif !File.exist?(key)
      error "private key not found: #{key.inspect}"
    end

    GitSSHWrapper.with_wrapper(:private_key_path => key) do |wrapper|
      wrapper.set_env
      system *command
      exit $?.exitstatus
    end

    exit 1
  end

  def print_help
    puts "Run remote git commands using only the specified ssh private key."
    puts
    puts usage
    exit 0
  end

  def print_version
    puts "git-ssh-wrapper version #{GitSSHWrapper::VERSION}"
    exit 0
  end

  def bin
    File.basename($0)
  end

  def usage
    "usage:\t#{bin} ssh.key command"
  end

  def error(message=nil)
    abort [message,usage].compact.join("\n")
  end
end
