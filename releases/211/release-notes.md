- System Monitor: a new **Processes** tab shows what NoGa OS and each app are running, the jobs NoGa OS does by itself with when each last ran, its threads with who owns them, and the programs it started on the computer; Ctrl+Alt+Del and Ctrl+Shift+Esc open the monitor on its Apps tab
- Kiosk: when the desktop stops responding, a screen appears after about ten seconds to restart NoGa OS or turn the computer off, and the event shows in the audit trail; run the kiosk installer again to get it
- Logging in and out is quicker, the login screen no longer reads every message to show who has new mail, and a profiler recording now survives closing the System Monitor and logging out

<details>
<summary>Checksum and signature</summary>

```
3bc19e8a1dad8bef111795a7a31f65aae8010701c053d5e786e7d28228a7d23e  nogaos-211.jar
```

The `.sha256` file is signed with the NoGa OS release key (`.sha256.sig`, Ed25519); the public key ships inside every build as `release-keys.pem`. To check a download by hand: `sha256sum -c nogaos-211.jar.sha256` and `openssl pkeyutl -verify -pubin -inkey release-keys.pem -rawin -in nogaos-211.jar.sha256 -sigfile nogaos-211.jar.sha256.sig`.

</details>

<details>
<summary>Included dependencies</summary>

| Library | Version | Size | License |
|:---|:---|---:|:---|
| `asm` | 9.10.1 | 123 KB | BSD-3-Clause |
| `common-image` | 3.14.0 | 77 KB | The BSD License |
| `common-io` | 3.14.0 | 90 KB | The BSD License |
| `common-lang` | 3.14.0 | 119 KB | The BSD License |
| `commonmark` | 0.30.0 | 214 KB | BSD-2-Clause |
| `commons-codec` | 1.22.0 | 410 KB | Apache-2.0 |
| `commons-compress` | 1.28.0 | 1091 KB | Apache-2.0 |
| `commons-io` | 2.20.0 | 550 KB | Apache-2.0 |
| `commons-lang3` | 3.18.0 | 686 KB | Apache-2.0 |
| `commons-logging` | 1.4.0 | 74 KB | Apache-2.0 |
| `error_prone_annotations` | 2.27.0 | 18 KB | Apache 2.0 |
| `fontbox` | 3.0.8 | 1608 KB | Apache-2.0 |
| `gluegen-rt` | v2.4.0 | 397 KB | BSD-2 License |
| `gson` | 2.11.0 | 291 KB | Apache-2.0 |
| `imageio-bmp` | 3.14.0 | 69 KB | The BSD License |
| `imageio-core` | 3.14.0 | 120 KB | The BSD License |
| `imageio-metadata` | 3.14.0 | 81 KB | The BSD License |
| `imageio-webp` | 3.14.0 | 79 KB | The BSD License |
| `jackson-annotations` | 2.22 | 82 KB | The Apache Software License, Version 2.0 |
| `jackson-core` | 3.2.1 | 590 KB | The Apache Software License, Version 2.0 |
| `jackson-databind` | 3.2.1 | 1927 KB | The Apache Software License, Version 2.0 |
| `JavaEWAH` | 1.2.3 | 166 KB | Apache 2 |
| `jcef-api` | jcef-d3de827+cef-146.0.10+g8219561+chromium-146.0.7680.179 | 216 KB | BSD License |
| `jcefmaven` | 146.0.10 | 30 KB | Apache-2.0 License |
| `jmdns` | 3.6.3 | 212 KB | Apache License, Version 2.0 |
| `jna-jpms` | 5.16.0 | 1956 KB | LGPL-2.1-or-later |
| `jna-platform-jpms` | 5.16.0 | 1344 KB | LGPL-2.1-or-later |
| `jogl-all` | v2.4.0 | 5031 KB | BSD-2 License |
| `jspecify` | 1.0.1 | 2 KB | The Apache License, Version 2.0 |
| `logback-classic` | 1.6.1 | 274 KB | EPL-2.0 |
| `logback-core` | 1.6.1 | 629 KB | EPL-2.0 |
| `org.eclipse.jgit` | 7.7.1.202607240634-r | 3348 KB | BSD-3-Clause |
| `pdfbox-io` | 3.0.8 | 50 KB | Apache-2.0 |
| `pdfbox` | 3.0.8 | 2022 KB | Apache-2.0 |
| `slf4j-api` | 2.0.18 | 68 KB | MIT |
| `vlcj-natives` | 4.12.0 | 93 KB | GPL v3 |
| `vlcj` | 4.12.1 | 399 KB | GPL v3 |

</details>
