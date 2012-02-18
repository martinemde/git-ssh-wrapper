# GitSSHWrapper

Encapsulate the code you need to write out a permissive GIT_SSH script that
can be used to connect git to protected git@github.com repositories.

## Example

    def get_refs
      wrapper = GitSSHWrapper.new(:private_key_path => '~/.ssh/id_rsa', :log_level => 'ERROR')
      `env #{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
    ensure
      wrapper.unlink
    end

OR

    # :log_level default in 'INFO'
    def get_refs
      GitSSHWrapper.new(:private_key_path => '~/.ssh/id_rsa') do |wrapper|
        `env #{wrapper.cmd_prefix} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
      end
    end

OR

    wrapper = GitSSHWrapper.new(:private_key => Pathname.new('id_rsa').read)

The wrapper creates Tempfiles when it is initialized. They will be cleaned at
program exit, or you can unlink them by calling #unlink like the example above.
