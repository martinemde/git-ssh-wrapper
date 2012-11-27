require 'spec_helper'

describe 'git-ssh script' do
  let(:bin)       { GIT_SSH_BIN }
  let(:usage)     { "usage:\tgit-ssh ssh.key command\n" }

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

  it "just calls git without args if you don't specify a command" do
    run_fails(bin, private_key_path).should == `git`
  end

  it "allows access to secure github repositories" do
    run_succeeds(bin, private_key_path, 'ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master')
  end

  it "exits with the status of the child command" do
    run_succeeds(bin, private_key_path, 'status')
    run_fails(bin, private_key_path, 'notfound')
  end

  it "does not delete the keyfile" do
    run_succeeds(bin, private_key_path, 'status')
    private_key_path.should exist
  end
end
