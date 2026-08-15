# Security Policy

## Supported versions

Vanta Panel follows a rolling release. The current 5.x line receives security
fixes; always run the latest version (currently 5.40).

| Version | Supported          |
| ------- | ------------------ |
| 5.x     | :white_check_mark: |
| < 5.0   | :x:                |

To update to the latest release, re-run the installer on your server:

```
curl -fsSL https://get.vantapanel.com | sudo bash
```

## Release integrity

Every Vanta Panel release is signed with an Ed25519 key. The installer and the
panel's auto-updater both verify a detached signature over `version|url|sha256`
against a public key pinned in the installer, in addition to a SHA-256 check.
A release that is tampered with, or served by anyone other than Vanta Panel,
**fails verification and is not installed**.

Public key (Ed25519, base64): `2g950+0wsBM3kjfr437q80GCYqM38BKvCpP6beZ6eRk=`

To download and verify a release without installing it:

```
VP_BOOTSTRAP_ONLY=1 curl -fsSL https://get.vantapanel.com | sudo bash
```

If you ever see `RELEASE SIGNATURE IS INVALID`, do not proceed — please report it
to security@vantapanel.com immediately.

## Reporting a vulnerability

If you believe you have found a security vulnerability in Vanta Panel, the
installer, or this repository, please report it privately.

- Email: **security@vantapanel.com**
- Please do **not** open a public GitHub issue for security reports.

Include as much detail as you can: affected version, a description of the issue,
steps to reproduce, and any proof-of-concept. If you would like to encrypt your
report, mention that in a first email and we will coordinate.

## Responsible disclosure

We ask that you give us a reasonable amount of time to investigate and issue a
fix before any public disclosure, and that you avoid accessing, modifying, or
destroying data belonging to others while researching. We will acknowledge your
report, keep you informed of progress, and credit you once a fix is released if
you would like to be credited.

Thank you for helping keep Vanta Panel and its users safe.
