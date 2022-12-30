# Dude

This action is triggered when a new issue has been created.  
Then it compares the new issue's contents with existing issues' contents, and detect possible duplications.  
If any possible duplication is detected, it will inform the issuer through comment.

**This action is partial: to use this action, you should copy `dune`, `dune-project` and `dup_scan.ml` from [the underlying repository](https://github.com/prosyslab/dude) into the root directory of your repository.**

## Inputs

## `issue_num`

**Required**  
The issue's number of which has been newly created.

## `issue_contents`

**Required**  
The issue's contents of which has been newly created.

## `repository_path_name`

**Required**  
The repository's path name.

## `rapid_key`

**Required**  
API Key of RapidAPI. You should pass this using GitHub Secrets. Refer to [this link](https://rapidapi.com/twinword/api/text-similarity).

## `repo_key` 

**Required**  
GitHub token. You could use pre-defined GitHub Secrets. Refer to [this link](https://docs.github.com/en/actions/security-guides/automatic-token-authentication).  
Or, you can use your own GitHub token.

## `threshold`

Threshold similarity to use for the detection. You should provide the valid number(0.0 ~ 1.0) only.  
If it is not specified, then it will be 0.20.

## Outputs

## `dup_num`

If any possible duplication is deteced, it will contains the issue number of it.  
Otherwise, it will be -1.

## Example usage
```
env:
  rapid_key: ${{ secrets.RAPID_KEY }}
  repo_key: ${{ secrets.GITHUB_TOKEN }}

...

uses: prosyslab/dude@v1.0.4 
with:   
  issue_num: ${{ github.event.issue.number }}
  issue_contents: ${{ github.event.issue.body }}
  repository_path_name: ${{ github.repository }}
  rapid_key: ${{ env.rapid_key }}
  repo_key: ${{ env.repo_key }}
  threshold: 0.2  # default: 0.2
```

## Plans for updates

- There will be several convenience functions we are currently planning to supports:  
  - Using tags, include & exclude some issues from scanning.  
  - Set default threshold value by inital scanning.  
  - Provide several options to scan & return.
