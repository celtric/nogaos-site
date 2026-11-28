- Chess: two kids can play each other by turns at the same keyboard, and a tournament seats 4 or 8 players, each a kid or a named computer player, so a whole family or class can play one knockout together
- **A kiosk or a window.** The Host computer applet's new **Mode** tab says how this computer runs NoGaOS: as a kiosk, the whole screen and the only program, which really shuts down, restarts and sleeps the computer; or as a program in a window beside the computer's own, maximised, which only closes when asked to shut down and shares the computer's clipboard. Only Linux has both: a kiosk, from the installer or home-made, counts as one until a grown-up chooses, a jar started on a Linux desktop opens in a window, and on Windows and macOS a window is the one way. Each thing the mode decides can be set the other way on the same tab, and what Shut down does is also on the Power applet's new **Shut down** tab.
- New **Host computer** applet in the Control Panel, for administrators: the System applet's Host tab becomes its **This computer** tab and the Host folders applet its **Mounted folders** tab; the trees of the System applet and of This computer wear the system's own icons, one per feature where there is a fitting one; the Mounted folders tab opens at once even while a share's computer has stopped answering, where it used to freeze the desktop.
- Local network: the tray's icon when the network is unplugged shows the two computers with a red cross; the Windows share wizard names the computers it finds (asking them the Windows way too), asks for a computer nearby or a typed address as one choice, tries each step on its own page so a computer that does not answer or a wrong password is said where it was typed, lists the folders the computer shares to pick from, puts every caption above its field, and never shows a terminal command, with one exception on purpose: wherever the administrator is needed, in the wizard, in the Mounted folders tab and in the programs installer alike, one **Review and approve** window shows the exact commands above the password field, runs them in place with a bar and each command's output unfolding under it, and closes only when the grown-up says so; a password the computer does not take asks again and changes nothing, so a folder is removed only once its setup is undone, and the tab says which share each folder is rather than a mount point; **Connect to a computer** in the explorer's tree opens on a double-click or Enter, not on selection.

<details>
<summary>Checksum and signature</summary>

```
0fc1397b7904de975a27765bbf40cefb7564ec0432980195dd5def392351ca85  nogaos-265.jar
```

The `.sha256` file is signed with the NoGaOS release key (`.sha256.sig`, Ed25519); the public key ships inside every build as `release-keys.pem`. To check a download by hand: `sha256sum -c nogaos-265.jar.sha256` and `openssl pkeyutl -verify -pubin -inkey release-keys.pem -rawin -in nogaos-265.jar.sha256 -sigfile nogaos-265.jar.sha256.sig`.

</details>

<details>
<summary>Included dependencies</summary>

| Library | Version | Size | License |
|:---|:---|---:|:---|
| `aopalliance` | 1.0 | 4 KB | Public Domain |
| `asm` | 9.11.1 | 128 KB | BSD-3-Clause |
| `checker-qual` | 3.12.0 | 203 KB | The MIT License |
| `common-image` | 3.15.3 | 77 KB | The BSD License |
| `common-io` | 3.15.3 | 90 KB | The BSD License |
| `common-lang` | 3.15.3 | 119 KB | The BSD License |
| `commonmark` | 0.31.0 | 215 KB | BSD-2-Clause |
| `commons-codec` | 1.19.0 | 365 KB | Apache-2.0 |
| `commons-compress` | 1.28.0 | 1091 KB | Apache-2.0 |
| `commons-io` | 2.20.0 | 550 KB | Apache-2.0 |
| `commons-lang3` | 3.18.0 | 686 KB | Apache-2.0 |
| `commons-logging` | 1.4.0 | 74 KB | Apache-2.0 |
| `error_prone_annotations` | 2.7.1 | 14 KB | Apache 2.0 |
| `failureaccess` | 1.0.1 | 4 KB | The Apache Software License, Version 2.0 |
| `fontbox` | 3.0.8 | 1608 KB | Apache-2.0 |
| `gson` | 2.11.0 | 291 KB | Apache-2.0 |
| `guava` | 31.0.1-jre | 2904 KB | Apache License, Version 2.0 |
| `guice` | 7.0.0 | 782 KB | The Apache Software License, Version 2.0 |
| `imageio-bmp` | 3.15.3 | 70 KB | The BSD License |
| `imageio-core` | 3.15.3 | 122 KB | The BSD License |
| `imageio-jpeg` | 3.15.3 | 92 KB | The BSD License |
| `imageio-metadata` | 3.15.3 | 81 KB | The BSD License |
| `imageio-webp` | 3.15.3 | 79 KB | The BSD License |
| `j2objc-annotations` | 1.3 | 8 KB | The Apache Software License, Version 2.0 |
| `jackson-annotations` | 2.22 | 82 KB | The Apache Software License, Version 2.0 |
| `jackson-core` | 3.2.4 | 598 KB | The Apache Software License, Version 2.0 |
| `jackson-databind` | 3.2.4 | 1943 KB | The Apache Software License, Version 2.0 |
| `jakarta.inject-api` | 2.0.1 | 10 KB | The Apache Software License, Version 2.0 |
| `jcef-api` | jcef-17e805a+cef-152.0.6+g708dc14+chromium-152.0.7977.83 | 218 KB | BSD License |
| `jcefmaven` | 152.0.6 | 30 KB | Apache-2.0 License |
| `jmdns` | 3.6.4 | 215 KB | Apache License, Version 2.0 |
| `jna-jpms` | 5.16.0 | 1956 KB | LGPL-2.1-or-later |
| `jna-platform-jpms` | 5.16.0 | 1344 KB | LGPL-2.1-or-later |
| `jspecify` | 1.0.1 | 2 KB | The Apache License, Version 2.0 |
| `jsr305` | 3.0.2 | 19 KB | The Apache Software License, Version 2.0 |
| `jsvg` | 2.0.0 | 706 KB | MIT |
| `listenablefuture` | 9999.0-empty-to-avoid-conflict-with-guava | 2 KB | The Apache Software License, Version 2.0 |
| `logback-classic` | 1.6.6 | 285 KB | EPL-2.0 |
| `logback-core` | 1.6.6 | 638 KB | EPL-2.0 |
| `pdfbox-io` | 3.0.8 | 50 KB | Apache-2.0 |
| `pdfbox` | 3.0.8 | 2022 KB | Apache-2.0 |
| `slf4j-api` | 2.0.20 | 68 KB | MIT |
| `vlcj-natives` | 4.12.0 | 93 KB | GPL v3 |
| `vlcj` | 4.12.1 | 399 KB | GPL v3 |

</details>
