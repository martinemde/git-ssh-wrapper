unless defined? Bundler
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'git-ssh-wrapper'
require 'rspec'

ROOT_PATH = Pathname.new("..").expand_path(File.dirname(__FILE__))

module SpecHelpers
  def exist
    be_exist
  end

  def private_key
    private_key_path.read
  end

  def private_key_path
    Pathname.new('spec/test_key').realpath
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
