- **Applications** (the App Manager renamed) installs apps from **catalogs**: a catalog is one file at a web address listing the apps its publisher offers. The **External apps** tab registers them, warning before one from outside NoGaOS is added, and each catalog is a tab of its own beside **Official apps**, with a care notice on top. Every jar is checked against the catalog's checksum, installed catalog apps keep themselves on the version their catalog publishes while automatic updates are on, and a policy may name catalogs and have the apps it lists installed from them. Sources that were GitHub repositories are gone; the catalog NoGaOS publishes is `https://celtric.github.io/nogaos-apps-repository/catalogs/experimental.json`.
- Space, Geography, Globe, Trigonometry and Bricks are no longer part of NoGaOS: they are experimental and live in that catalog, so a computer that had them gets them back by registering it, or by following a policy that names it. Learn languages is gone.
- Fixes: the Log Viewer shows errors in red and warnings in orange; the audit trail no longer records the value of a credential header.

<details>
<summary>Checksum and signature</summary>

```
32f05aae939c6a93fbc9f5cb25d4fdc0ecd9dcdebd61395558d9ce0f52fd5f78  nogaos-244.jar
```

The `.sha256` file is signed with the NoGaOS release key (`.sha256.sig`, Ed25519); the public key ships inside every build as `release-keys.pem`. To check a download by hand: `sha256sum -c nogaos-244.jar.sha256` and `openssl pkeyutl -verify -pubin -inkey release-keys.pem -rawin -in nogaos-244.jar.sha256 -sigfile nogaos-244.jar.sha256.sig`.

</details>

<details>
<summary>Included dependencies</summary>

| Library | Version | Size | License |
|:---|:---|---:|:---|
| `aopalliance` | 1.0 | 4 KB | Public Domain |
| `asm` | 9.11.1 | 128 KB | BSD-3-Clause |
| `asn-one` | 0.6.0 | 65 KB | The Apache License, Version 2.0 |
| `bcprov-jdk18on` | 1.85.2 | 10039 KB | Bouncy Castle Licence |
| `checker-qual` | 3.12.0 | 203 KB | The MIT License |
| `common-image` | 3.15.3 | 77 KB | The BSD License |
| `common-io` | 3.15.3 | 90 KB | The BSD License |
| `common-lang` | 3.15.3 | 119 KB | The BSD License |
| `commonmark` | 0.31.0 | 215 KB | BSD-2-Clause |
| `commons-codec` | 1.22.1 | 412 KB | Apache-2.0 |
| `commons-compress` | 1.28.0 | 1091 KB | Apache-2.0 |
| `commons-io` | 2.20.0 | 550 KB | Apache-2.0 |
| `commons-lang3` | 3.18.0 | 686 KB | Apache-2.0 |
| `commons-logging` | 1.4.0 | 74 KB | Apache-2.0 |
| `error_prone_annotations` | 2.27.0 | 18 KB | Apache 2.0 |
| `failureaccess` | 1.0.1 | 4 KB | The Apache Software License, Version 2.0 |
| `fontbox` | 3.0.8 | 1608 KB | Apache-2.0 |
| `gluegen-rt` | v2.4.0 | 397 KB | BSD-2 License |
| `gson` | 2.11.0 | 291 KB | Apache-2.0 |
| `guava` | 31.0.1-jre | 2904 KB | Apache License, Version 2.0 |
| `guice` | 7.0.0 | 782 KB | The Apache Software License, Version 2.0 |
| `imageio-bmp` | 3.15.3 | 70 KB | The BSD License |
| `imageio-core` | 3.15.3 | 122 KB | The BSD License |
| `imageio-metadata` | 3.15.3 | 81 KB | The BSD License |
| `imageio-webp` | 3.15.3 | 79 KB | The BSD License |
| `j2objc-annotations` | 1.3 | 8 KB | The Apache Software License, Version 2.0 |
| `jackson-annotations` | 2.22 | 82 KB | The Apache Software License, Version 2.0 |
| `jackson-core` | 3.2.4 | 598 KB | The Apache Software License, Version 2.0 |
| `jackson-databind` | 3.2.4 | 1943 KB | The Apache Software License, Version 2.0 |
| `jakarta.inject-api` | 2.0.1 | 10 KB | The Apache Software License, Version 2.0 |
| `JavaEWAH` | 1.2.3 | 166 KB | Apache 2 |
| `jcef-api` | jcef-17e805a+cef-152.0.6+g708dc14+chromium-152.0.7977.83 | 218 KB | BSD License |
| `jcefmaven` | 152.0.6 | 30 KB | Apache-2.0 License |
| `jmdns` | 3.6.4 | 215 KB | Apache License, Version 2.0 |
| `jna-jpms` | 5.16.0 | 1956 KB | LGPL-2.1-or-later |
| `jna-platform-jpms` | 5.16.0 | 1344 KB | LGPL-2.1-or-later |
| `jogl-all` | v2.4.0 | 5031 KB | BSD-2 License |
| `jspecify` | 1.0.1 | 2 KB | The Apache License, Version 2.0 |
| `jsr305` | 3.0.2 | 19 KB | The Apache Software License, Version 2.0 |
| `listenablefuture` | 9999.0-empty-to-avoid-conflict-with-guava | 2 KB | The Apache Software License, Version 2.0 |
| `logback-classic` | 1.6.6 | 285 KB | EPL-2.0 |
| `logback-core` | 1.6.6 | 638 KB | EPL-2.0 |
| `mbassador` | 1.3.2 | 96 KB | MIT license |
| `org.eclipse.jgit` | 7.8.0.202609011348-r | 3367 KB | BSD-3-Clause |
| `pdfbox-io` | 3.0.8 | 50 KB | Apache-2.0 |
| `pdfbox` | 3.0.8 | 2022 KB | Apache-2.0 |
| `slf4j-api` | 2.0.20 | 68 KB | MIT |
| `smbj` | 0.15.0 | 667 KB | The Apache License, Version 2.0 |
| `vlcj-natives` | 4.12.0 | 93 KB | GPL v3 |
| `vlcj` | 4.12.1 | 399 KB | GPL v3 |

</details>
