# Build dependencies

The common libraries are preserved from OpenRadioss_extlib v67, commit
`f10f11a4ba6943e2d950ac12da47461ea7b8f05d`:
https://github.com/AgenteScontro/OpenRadioss_extlib

Input readers were recovered separately from public OpenRadioss runtime
packages. `../EXTLIB_VERSION.json` records their sources and SHA256 checksums.
Original reader and third-party notices are under each platform's
`hm_reader/<platform>/notices` directory. Other libraries retain their original
notices in their own directories.

This collection is not the original v82 archive. The compatibility builds reject
`/ALE/STRUCTURED_MESH`: the Linux reader lacks the generator, and the Windows
trial produced invalid node coordinates. See
[Building and running](../doc/BUILDING.md) for the supported configurations.
