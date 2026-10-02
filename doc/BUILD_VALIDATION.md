# Build validation

Checked on 2026-10-02 with double precision, SMP and one solver thread:

| Platform | Toolchain | Solver checks |
| --- | --- | --- |
| Ubuntu / WSL x86-64 | GCC and GFortran 13.3.0, CMake 3.28.3 | Starter and Engine built; nine bundled MiniQA cases terminated normally and agreed with their stored references within the existing tolerances |
| Windows x86-64 | Intel oneAPI 2023.0.0, ifx and icx, CMake and Ninja | Starter and Engine built; the same nine MiniQA cases agreed with their stored references within the existing tolerances |

The selected MiniQA cases are `1.01`, `1.03`, `1.04`, `1.05`, `1.10`, `1.17`,
`1.64`, `1.68` and `1.84`. They cover accelerometers, ALE, shell elements, crash,
contact, plasticity, SPH, an equation of state and the twisted-beam smoke model.
References and tolerances were unchanged. The SPH include file needed its
copyright header marked as comments before the reader could parse the model.

Additional checks:

- Both readers handled empty and multiple include lists, a 96-byte filename and
  a short destination buffer without overwriting its guards.
- Part element counts of 3, 24, 96 and 0 agreed with the newer reader's nonempty
  part query. The Linux compatibility routine rejects a mismatched selected ID.
- A rigid part generated through `/PART`'s `Irigid` field completed Starter and
  Engine on both platforms.
- The twisted-beam model produced H3D output at five times from 0 to 0.02. The
  bundled H3D readers opened the files, read their string tables and closed them.
  This checks output availability and basic readability, not every result value
  in every frame.
- Both compatibility builds report the unsupported `/ALE/STRUCTURED_MESH` keyword and exit with
  status 2. It does not substitute an empty mesh generator.
- An explicit 27-node, 8-element fluid mesh completed Starter and Engine on both
  platforms. The Windows automatic structured-mesh trial produced zero-volume
  elements with both the rebuilt and the preserved official Starter; the Windows
  compatibility helper also disables automatic generation.
- Engine help returns 0; invalid command-line arguments return 2 without the
  early-startup crash observed before the fix.

These checks cover the configurations above. They do not establish equivalence
to the unavailable v82 package or validate every solver option. See
[Building and running](BUILDING.md) for compatibility limits and commands.
