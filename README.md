# git-tastic

A set of bash and powershell scripts to improve your git experience.

## Changing your default git editor

Taken from [Github documentation](https://docs.github.com/en/get-started/getting-started-with-git/associating-text-editors-with-git)

### VSCode

```bash
    git config --global core.editor "code --wait"
```

### Atom

```bash
    git config --global core.editor "atom --wait"
```

## A typical development workflow using the aliases

- Pull latest changes for the current branch AND create a new branch AND push the new bramch the remote: `git cbp <branch name>`
- Do some changes in this new branch
- Add all files to the staging area AND commit with a message: `git cm <commit message>`
- Do more changes
- Add all files to the staging area AND commit with a message AND push it to the remote: `git cmp <commit message>`
- Delete the branch after work is done AND move to main branch AND pull latest changes AND prune all local branches that don't exist in the remote: `git md`
  - this can be used after a PR has been merged and the remote branch has been deleted.
