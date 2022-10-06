# Dude

This action is triggered when a new issue has created.   
Then it compares the new issue's contents with existing issues' contents, and detect possible duplications.

## Inputs

## `issue_num`

**Required** The issue's number.

## `issue_contents`

**Required** The issue's contents.

## Outputs

## `dup`

If possible duplications are deteced, it will contains the list of existing issues.
(`not yet implemented!!`)

## Example usage

<!-- uses: actions/hello-world-docker-action@v1 -->
<!-- with:
  who-to-greet: 'Mona the Octocat' -->

```
uses: actions/ocaml-test-action@v1 # not yet published!!   
with:   
    issue_num: ${{ github.event.issue.number }}   
    issue_contents: ${{ github.event.issue.body }}
```