require 'spec_helper'

describe 'git-ssh-wrapper script' do
  let(:root)      { Pathname.new("..").expand_path(File.dirname(__FILE__)) }
  let(:print_env) { root.join('spec/print_env') }
  let(:bin)       { root.join('bin/git-ssh-wrapper') }
  let(:usage)     { "usage:\tgit-ssh-wrapper ssh.key git command\n" }

  def run(*args)
    cmd = [bin] + args
    `#{cmd.flatten.join(' ')} 2>&1`
  end

  it "prints usage information with no args" do
    run.should == usage
  end

  it "prints help on -h, --help, or help" do
    help = "Run git commands using only the specified ssh private key.\n\n#{usage}"
    run('-h').should == help
    run('help').should == help
    run('--help').should == help
  end

  it "aborts if you didn't specify a key" do
    run('git st').should == "private key not found: \"git\"\n#{usage}"
  end

  it "aborts if you didn't specify a command" do
    run(private_key_path).should == usage
  end

  it "allows access to secure github repositories" do
    run(private_key_path, 'git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master')
    $?.should be_true
  end

  it "sets the GIT_SSH environment variable" do
    run(private_key_path, print_env).chomp.should =~ /git-ssh-wrapper/ # the tempfile includes this in the name
  end

  it "cleans up after execution" do
    run(private_key_path, 'true')
    `#{print_env}`.chomp.should be_empty
    ENV['GIT_SSH'].should be_nil
  end

  it "does not delete the keyfile" do
    run(private_key_path, 'true')
    Pathname.new(private_key_path).should exist
  end
end
