# Create Milestone Action

Github Action to automatically create future dated milestones upon marking a pull request as ready for review.

## Example Github Action Workflow File

```
name: Create Milestone

on:
  pull_request:
    types: [ready_for_review]
  workflow_dispatch:

jobs:
  create-milestone:
    name: Create Milestone
    runs-on: ubuntu-latest
    steps:
    - name: Run Create Milestone Action
      id: run-create-milestone-action
      uses: DanS01/Create-Milestone-Action@v1.1
      with:
        secrets-token: ${{ secrets.GITHUB_TOKEN }}
```
