unless defined? Bundler
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'git-ssh-wrapper'
require 'spec'
require 'open4'

module TestPrivateKey
  def private_key
    private_key_path.read
  end

  def private_key_path
    Pathname.new('spec/test_key').realpath
  end
end

Spec::Runner.configure do |config|
  config.include TestPrivateKey
end
