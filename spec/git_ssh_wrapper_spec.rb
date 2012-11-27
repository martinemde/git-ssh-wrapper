require 'spec_helper'

describe GitSSHWrapper do
  shared_examples_for "a GIT_SSH wrapper" do
    it "allows access to secure github repositories" do
      `#{subject.cmd_prefix} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master 2>&1`
      $?.should be_true
    end

    it "has a script path that really exists" do
      lambda { subject.pathname.realpath }.should_not raise_error
    end

    it "formats a string with the GIT_SSH= in front of the script" do
      subject.git_ssh.should == "GIT_SSH='#{subject.path}'"
    end

    it "disappears when unlinked" do
      pathname = subject.pathname
      subject.unlink
      pathname.should_not exist
    end
  end

  context "with a key string" do
    subject { described_class.new(:private_key => private_key) }
    after { subject.unlink }
    it_should_behave_like "a GIT_SSH wrapper"
  end

  context "with a key file" do
    subject { described_class.new(:private_key_path => private_key_path) }
    after { subject.unlink }
    it_should_behave_like "a GIT_SSH wrapper"

    it "should not delete the keyfile when unlinked" do
      private_key_path.should exist
      subject.unlink
      private_key_path.should exist
    end
  end

  context "without a key" do
    it "should raise a PrivateKeyRequired error (ArgumentError)" do
      # the errors are the same, alternating just to ensure inheritence
      lambda { described_class.new({}) }.should raise_error(GitSSHWrapper::PrivateKeyRequired)
      lambda { described_class.new(:private_key => '') }.should raise_error(ArgumentError)
      lambda { described_class.new(:private_key_path => '') }.should raise_error(GitSSHWrapper::PrivateKeyRequired)
    end
  end

  context "#with_git_ssh" do
    it "allows access to secure github repositories" do
      GitSSHWrapper.with_wrapper(:private_key => private_key) do |wrapper|
        `#{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master 2>&1`
        $?.should be_true
      end
    end

    it "allows less noisy ssh" do
      GitSSHWrapper.with_wrapper(:private_key => private_key, :log_level => "info") do |wrapper|
        `#{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master 2>&1`.should include("Warning: Permanently added 'github.com' (RSA) to the list of known hosts.")
      end

      GitSSHWrapper.with_wrapper(:private_key => private_key, :log_level => "error") do |wrapper|
        `#{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master 2>&1`.should_not include("Warning: Permanently added 'github.com' (RSA) to the list of known hosts.")
      end
    end

    it "has a script path that really exists" do
      GitSSHWrapper.with_wrapper(:private_key => private_key) do |wrapper|
        lambda { wrapper.pathname.realpath }.should_not raise_error
      end
    end

    it "formats a string with the GIT_SSH= in front of the script" do
      GitSSHWrapper.with_wrapper(:private_key => private_key) do |wrapper|
        wrapper.git_ssh.should == "GIT_SSH='#{wrapper.path}'"
      end
    end

    it "disappears when unlinked" do
      pathname = nil
      GitSSHWrapper.with_wrapper(:private_key => private_key) do |wrapper|
        pathname = wrapper.pathname
      end
      pathname.should_not be_exist
    end
  end
end
