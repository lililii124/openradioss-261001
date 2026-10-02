# Source provenance

This independent repository preserves the following upstream source revision:

```text
Original repository: https://github.com/OpenRadioss/OpenRadioss
Original branch:     main
Source date:         2026-09-29
Commit:              1a0d691b82bd4f94a3bc2399682551e84e1d5fa4
Tree:                66e173d1e043b341b14a7fe984c1a26c1d36a235
Parent:              e386ba1a7f618be69cc7a16fe45507aff55c075c
Author:              yz (GitHub: lililii124)
Committer:           sebastienVilleneuve
Subject:             Add three-surface RHT solid USER01 material and verification tools
```

The revision was retained in a local checkout of upstream `main`. Its full
ancestry was recovered from the surviving `lililii124/OpenRadioss` fork; that
fork's ZWT branch descends directly from this revision. The preserved history is
not shallow and contains 5,149 commits through the source revision. The source
tree contains 10,562 tracked files, with no Git submodules or Git LFS attributes.

The exact tag `upstream-20260929` points to the original commit. The community
README and these provenance files are added in a separate descendant commit.
No solver source changes are introduced by the archive setup.

## Verify the preserved objects

```bash
git clone https://github.com/lililii124/openradioss-261001.git
cd openradioss-261001
git rev-parse upstream-20260929
git rev-parse upstream-20260929^{tree}
git rev-parse --is-shallow-repository
git rev-list --count upstream-20260929
git show --no-patch --format=fuller upstream-20260929
git fsck --connectivity-only --no-reflogs --no-dangling upstream-20260929
```

The expected commit and tree IDs are listed above; the shallow flag is `false`
and the history count is `5149` for a full clone. The setup was checked for
missing Git objects before publication. Build and material validation procedures
remain documented in the upstream source; archive integrity checks do not
constitute a new solver validation.

## Historical RHT pull request record

[PR_5287.saved-record.json](provenance/PR_5287.saved-record.json) is an excerpt
from a locally retained GitHub API snapshot captured on 2026-10-01. It records:

- Original PR: `OpenRadioss/OpenRadioss#5287`.
- State: `MERGED`; review decision: `APPROVED`.
- Merged at: `2026-09-29T08:10:14Z`.
- Merged by: `sebastienVilleneuve`.

The original upstream repository became unavailable before this archive was
published. The saved record is historical evidence, not a current response from
the original repository. It is not cryptographically authenticated. The
preserved commit is also unsigned: its author and committer fields alone do not
prove that upstream accepted it. This repository makes those distinctions
explicit rather than presenting a community-hosted commit as an official PR
page.

[upstream-snapshot.json](provenance/upstream-snapshot.json) provides the source
identity and archive scope in machine-readable form.
