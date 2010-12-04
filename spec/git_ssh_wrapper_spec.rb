require 'spec_helper'

describe GitSSHWrapper do
  shared_examples_for "a GIT_SSH wrapper" do
    it "allows access to secure github repositories" do
      lambda {
        Open4.spawn("#{@git_ssh_wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master", :stdout => '', :stderr => '')
      }.should_not raise_error
    end

    it "has a script path that really exists" do
      lambda { @git_ssh_wrapper.pathname.realpath }.should_not raise_error
    end

    it "formats a string with the GIT_SSH= in front of the script" do
      @git_ssh_wrapper.git_ssh.should == "GIT_SSH='#{@git_ssh_wrapper.path}'"
    end

    it "disappears when unlinked" do
      pathname = @git_ssh_wrapper.pathname
      @git_ssh_wrapper.unlink
      pathname.should_not be_exist # ;_; syntax h8
    end
  end

  context "with a key string" do
    before { @git_ssh_wrapper = described_class.new(:private_key => private_key) }
    after { @git_ssh_wrapper.unlink }
    it_should_behave_like "a GIT_SSH wrapper"
  end

  context "with a key file" do
    before { @git_ssh_wrapper = described_class.new(:private_key_path => private_key_path) }
    after { @git_ssh_wrapper.unlink }
    it_should_behave_like "a GIT_SSH wrapper"

    it "should not delete the keyfile when unlinked" do
      pathname = Pathname.new(private_key_path)
      pathname.should be_exist
      @git_ssh_wrapper.unlink
      pathname.should be_exist
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
        lambda {
          Open4.spawn("#{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git refs/heads/master", :stdout => '', :stderr => '')
        }.should_not raise_error
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
