# GitSSHWrapper

Encapsulate the code you need to write out a permissive GIT_SSH script that
can be used to connect git to protected git@github.com repositories.

## Example

    def get_refs
      wrapper = GitSSHWrapper.new(:private_key_path => '~/.ssh/id_rsa')
      `env #{wrapper.git_ssh} git ls-remote git@github.com:martinemde/git-ssh-wrapper.git`
    ensure
      wrapper.unlink
    end

OR

    GitSSHWrapper.new(:private_key => Pathname.new('id_rsa').read)

The wrapper creates Temfiles when it is initialized. They will be cleaned at
program exit, or you can unlink them by calling #unlink like the example above.
