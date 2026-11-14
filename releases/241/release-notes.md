- Managed computers: a policy is now signed with an **identity**, a file of its own made from the Fleet applet with a password and a few seconds of moving the mouse, kept wherever its owner wants and never on the computer; a double-click on it shows its fingerprint and checks the password. The Policy Editor opens for reading, with a **History** tab of every revision and what changed, and edits only after **Edit**; every policy carries that history inside, signed, so a computer refuses a rewritten one. Policies and identities from version 239 must be made again.
- Desktop: Alt+Tab switches between windows; a window opened on its own lands in the centre again; the Control Panel opens wide enough for its icons; a long message in a dialog wraps instead of stretching it; the screen saver no longer flashes before a laptop sleeps when both are set to the same time.
- Personal Web Server: the folder to show is remembered per user and starts as a `www` folder with a home page, made at the first **Start**, with a button that opens it in the explorer; the share scanner of the Networks applet lists this computer too when it shares files.

<details>
<summary>Checksum and signature</summary>

```
966f66f8850c8b51143066e85041a1542d93f953086835c85a22ffcdf51635ea  nogaos-241.jar
```

The `.sha256` file is signed with the NoGaOS release key (`.sha256.sig`, Ed25519); the public key ships inside every build as `release-keys.pem`. To check a download by hand: `sha256sum -c nogaos-241.jar.sha256` and `openssl pkeyutl -verify -pubin -inkey release-keys.pem -rawin -in nogaos-241.jar.sha256 -sigfile nogaos-241.jar.sha256.sig`.

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
