unless defined? Bundler
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'git-ssh-wrapper'
require 'rspec'

ROOT_PATH        = Pathname.new("..").expand_path(File.dirname(__FILE__))
PRIVATE_KEY_PATH = ROOT_PATH.join('spec/test_key').realpath.freeze
PRIVATE_KEY      = PRIVATE_KEY_PATH.read.freeze
GIT_SSH_BIN      = ROOT_PATH.join('bin/git-ssh').freeze
WRAPPER_BIN      = ROOT_PATH.join('bin/git-ssh-wrapper').freeze
PRINT_ENV_SCRIPT = ROOT_PATH.join('spec/print_env').freeze

module SpecHelpers
  def exist
    be_exist
  end

  def private_key
    PRIVATE_KEY
  end

  def private_key_path
    PRIVATE_KEY_PATH
  end

  def print_env_script
    PRINT_ENV_SCRIPT
  end

  def run_succeeds(bin, *args)
    cmd = ([bin] + args).flatten.join(' ')
    ret = `#{cmd} 2>&1`
    if !$?.success?
      fail "Expected exit status 0, got #{$?.exitstatus}.\n\t#{cmd}\n\t#{ret}"
    end
    ret
  end

  def run_fails(bin, *args)
    cmd = ([bin] + args).flatten.join(' ')
    ret = `#{cmd} 2>&1`
    if $?.success?
      fail "Expected failure.\n\t#{cmd}\n\t#{ret}"
    end
    ret
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
