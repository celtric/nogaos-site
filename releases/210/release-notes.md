- Installed apps can no longer read the computer's system properties, such as the home folder or the operating system name; the sandbox refuses them at install and while running
- Media Player and Worksheets: a VLC installed only for the current user on Windows or macOS is no longer found, so install VLC for all users

<details>
<summary>Checksum and signature</summary>

```
7ee5d0a88205fb464bd7541c00bab6c5b4bcfdbbb72ded6519d4487ce68c94dd  nogaos-210.jar
```

The `.sha256` file is signed with the NoGa OS release key (`.sha256.sig`, Ed25519); the public key ships inside every build as `release-keys.pem`. To check a download by hand: `sha256sum -c nogaos-210.jar.sha256` and `openssl pkeyutl -verify -pubin -inkey release-keys.pem -rawin -in nogaos-210.jar.sha256 -sigfile nogaos-210.jar.sha256.sig`.

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
