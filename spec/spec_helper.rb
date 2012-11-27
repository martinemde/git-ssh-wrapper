unless defined? Bundler
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'git-ssh-wrapper'
require 'rspec'
require 'open4'

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
end

RSpec.configure do |config|
  config.include SpecHelpers
end
