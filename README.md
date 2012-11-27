# GitSSHWrapper

Encapsulate the code you need to write out a permissive GIT\_SSH script that
can be used to connect git to protected git@github.com repositories.

Includes two bin scripts, `git-ssh-wrapper` and `git-ssh` that can be used
inline to call git with GIT\_SSH set properly. See examples below.

## What it does

This gem provides a simple way to connect to git servers using keys that have
not been added to your authentication agent with ssh-add, or keys which you
only have saved as a string instead of written to a file.

This is especially useful for scripts that need to automate connections to a
server using keys that are not intended to be part of the system on which the
script is running.

This script is designed to *always work* even if hosts keys change or the ssh
agent is being too paranoid or having a bad day.

A common use case is connecting to github.com to retrieve repositories,
submodules, or ref listings using read-only "deploy keys" or bundling a Gemfile
that contains private repositories accessible by a certain deploy key.

## Command Line

You can use the included command line tool to call git commands directly.

    $ git-ssh-wrapper ~/.ssh/id_rsa git fetch origin
    $ git merge origin/master
    $ git-ssh-wrapper ~/.ssh/id_rsa git push origin master

    $ git-ssh-wrapper ~/.ssh/id_rsa bundle install

A shortcut command `git-ssh` is also included that inserts `git` automatically.

    $ git-ssh ~/.ssh/id_rsa fetch origin  # git fetch origin

You'll probably use this version if you're writing commands by hand.

## Ruby Example

Accessing git servers programatically in ruby:

    # :log_level default is 'INFO'
    def get_refs
      wrapper = GitSSHWrapper.new(:private_key_path => '~/.ssh/id_rsa', :log_level => 'ERROR')
      `env #{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
    ensure
      wrapper.unlink
    end

OR

    def get_refs
      private_key_data_string = get_key_data_somehow
      GitSSHWrapper.with_wrapper(:private_key => private_key_data_string) do |wrapper|
        wrapper.set_env
        `git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
      end
    end

OR

    wrapper = GitSSHWrapper.new(:private_key => Pathname.new('id_rsa').read)
    `git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
    wrapper.unlink

The wrapper creates Tempfiles when it is initialized. They will be cleaned at
program exit, or you can unlink them by calling #unlink.

## How it works

When connecting to a git server using ssh, if the GIT\_SSH environment variable
is set, git will use $GIT\_SSH instead of `ssh` to connect.

The script generated will look something like this:
(as long as I've kept this documentation up-to-date properly)

    unset SSH_AUTH_SOCK
    ssh -o CheckHostIP=no \
        -o IdentitiesOnly=yes \
        -o LogLevel=LOG_LEVEL \
        -o StrictHostKeyChecking=no \
        -o PasswordAuthentication=no \
        -o UserKnownHostsFile=TEMPFILE \
        -o IdentityFile=PRIVATE_KEY_PATH \
        $*

The result is an ssh connection that won't use your ssh-added keys, won't prompt
for passwords, doesn't save known hosts and doesn't require strict host key
checking.

A tempfile is generated to absorb known hosts to prevent these constant warnings:
`Warning: Permanently added 'xxx' (RSA) to the list of known hosts.`

The tempfile is cleaned when the wrapper is unlinked or the program exits.
