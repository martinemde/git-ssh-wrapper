require 'spec_helper'

describe 'git-ssh-wrapper script' do
  let(:bin)       { WRAPPER_BIN }
  let(:usage)     { "usage:\tgit-ssh-wrapper ssh.key command\n" }

  it "prints usage information with no args" do
    run_fails(bin).should == usage
  end

  it "prints help on -h, --help, or help" do
    help = "Run remote git commands using only the specified ssh private key.\n\n#{usage}"
    run_succeeds(bin, '-h').should == help
    run_succeeds(bin, 'help').should == help
    run_succeeds(bin, '--help').should == help
  end

  it "aborts if you don't specify a key" do
    run_fails(bin, 'git st').should == "private key not found: \"git\"\n#{usage}"
  end

  it "aborts if you didn't specify a command" do
    run_fails(bin, private_key_path).should == usage
  end

  it "allows access to secure github repositories" do
    run_succeeds(bin, private_key_path, 'git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master')
  end

  it "can be used to bundle private gem repositories" do
    Bundler.with_clean_env do
      run_succeeds(bin, private_key_path, "bundle install --gemfile #{ROOT_PATH.join('spec/private_gemfile.rb')}")
    end
  end

  it "sets the GIT_SSH environment variable" do
    run_succeeds(bin, private_key_path, print_env_script).chomp.should =~ /git-ssh-wrapper/ # the tempfile includes this in the name
  end

  it "cleans up after execution" do
    run_succeeds(bin, private_key_path, 'true')
    `#{print_env_script}`.chomp.should be_empty
    ENV['GIT_SSH'].should be_nil
  end

  it "exits with the status of the child command" do
    run_succeeds(bin, private_key_path, 'true')
    run_fails(bin, private_key_path, 'false')
  end

  it "does not delete the keyfile" do
    run_succeeds(bin, private_key_path, 'true')
    private_key_path.should exist
  end
end
