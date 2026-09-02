# Development Workflow

This repository is archived, but historical documentation maintenance follows a two-branch workflow.

1. Make all changes on `develop` or a short-lived branch based on `develop`.
2. Open a pull request from `develop` to `main` after review.
3. Use **Create a merge commit**; do not rebase the two long-lived branches.
4. Create release tags only from `main`.
5. Merge the updated `main` back into `develop` after every release.

Direct pushes and force pushes to `main` are not part of the normal workflow.
