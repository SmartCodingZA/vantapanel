# Vanta Panel — a self-hosted cPanel alternative

**Vanta Panel is a web hosting control panel you install on your own Ubuntu or Debian VPS with one command. It is a cPanel & WHM alternative that charges per server, never per account: free for one hosting account, $5 a month for five, $10 a month for unlimited.**

[![Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fget.vantapanel.com%2Fupdate.json&query=%24.version&prefix=v&label=version&color=2b7fff)](https://vantapanel.com/releases)
[![Released](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fget.vantapanel.com%2Fupdate.json&query=%24.released&label=released&color=555)](https://vantapanel.com/releases)
[![License](https://img.shields.io/badge/license-proprietary-lightgrey)](https://vantapanel.com/pricing)
[![Self-hosted](https://img.shields.io/badge/self--hosted-yes-brightgreen)](https://vantapanel.com)
[![Install](https://img.shields.io/badge/install-one%20command-blueviolet)](https://get.vantapanel.com)

Like cPanel, it has two apps: **vWHM** for the server administrator and **vPanel** for each hosting customer. Unlike cPanel, everything a hosting customer pays for runs on your server and is included in every tier: a mail server with webmail, authoritative DNS with private nameservers on your brand, free SSL, backups, a free first-party WHMCS module, an importer for cPanel account backups, and managed Node.js, Python, Java, Kafka and Redis next to PHP sites.

- **Website:** [vantapanel.com](https://vantapanel.com) · **Pricing:** [vantapanel.com/pricing](https://vantapanel.com/pricing)
- **Compare:** [the best cPanel alternatives](https://vantapanel.com/cpanel-alternative) · [Vanta Panel vs cPanel & WHM](https://vantapanel.com/vs/cpanel) · [vs HestiaCP](https://vantapanel.com/vs/hestiacp) · [every panel in one table](https://vantapanel.com/compare)
- **Releases:** [release history](https://vantapanel.com/releases) · [security advisories](https://vantapanel.com/security/advisories)
- **Docs:** [vantapanel.com/docs](https://vantapanel.com/docs) · **Live demo:** [demo.vantapanel.com](https://demo.vantapanel.com)

## Install

```bash
curl -fsSL https://get.vantapanel.com | sudo bash
```

**Requirements:** a fresh Ubuntu 22.04 or newer, or Debian 12 or newer, server (x86_64 or arm64), about 2 GB of RAM, about 3 GB of free disk, root access, and nothing already bound to ports 80 and 443. Both panels and the whole hosting stack are live in about three minutes. Running the same command again later upgrades in place and keeps your data.

## Try the live demo

No signup, no install: a real running instance, read-only, reset every hour.

| App | URL | Login |
| --- | --- | --- |
| vWHM (admin) | [demo.vantapanel.com/vwhm](https://demo.vantapanel.com/vwhm) | `demo` / `demo` |
| vPanel (customer) | [demo.vantapanel.com/vpanel](https://demo.vantapanel.com/vpanel) | `acme` / `demo` |

## How it compares with cPanel and the other panels

Every cell on the website's comparison pages links to the vendor's own page and carries the date it was checked. The short version:

| | Vanta Panel | cPanel & WHM | HestiaCP | CloudPanel |
| --- | --- | --- | --- | --- |
| Licence | $0 / $5 / $10 per server per month, never per account | Per server, priced by account count: $29.99 to $69.99 a month, then $0.49 per account above 100 | Free, GPLv3 | Free, proprietary |
| Mail server and webmail | Yes (Postfix, Dovecot, Roundcube) | Yes | Yes | No |
| Authoritative DNS and private nameservers | Yes (PowerDNS) | Yes | Yes | No |
| A login for every hosting customer | Yes (vPanel) | Yes | Yes | Partial (roles) |
| WHMCS provisioning module | Yes, first-party and free | Yes | Third-party | No |
| Import cPanel accounts | Yes, from a vWHM screen | n/a | Yes, command line | No |
| Node.js, Python, Java, Kafka | Yes | Node.js | No | Node.js, Python |
| Operating systems | Ubuntu 22.04+, Debian 12+ | AlmaLinux, CloudLinux, Rocky, Ubuntu 24.04 | Debian, Ubuntu | Debian, Ubuntu |

Sources and dates: [vantapanel.com/compare](https://vantapanel.com/compare). Plesk, DirectAdmin, CyberPanel, Virtualmin, ISPConfig, aaPanel, Froxlor and OpenPanel are covered in [the full round-up](https://vantapanel.com/cpanel-alternative).

## Features

Every service below is built in, and every one is available in every tier, the free tier included.

| Service | What it does |
| --- | --- |
| Hosting accounts | Isolated Linux users with disk quotas and their own PHP-FPM pool |
| Domains, subdomains and aliases | Add, park and route domains; preview a site before its DNS moves |
| Email and webmail | Mailboxes, forwarders, autoresponders, Sieve filters, spam filtering, Roundcube webmail, CalDAV/CardDAV |
| Authoritative DNS | PowerDNS on your server with a zone editor and private nameservers; optional Cloudflare integration |
| MySQL/MariaDB databases | Databases, users, remote access and phpMyAdmin |
| Free SSL | Automatic HTTPS via Let's Encrypt, or install your own certificate |
| File manager and Web Disk | Browse, edit and upload in the browser; mount an account as a network drive (WebDAV) |
| Backups | Scheduled and on-demand, to local disk, S3-compatible storage, FTP/FTPS, SFTP or WebDAV |
| cPanel import | Import a cPanel account backup: sites, databases, mail and cron |
| WHMCS module | Free first-party module: create, suspend, unsuspend, terminate, change package |
| Resellers | Give a partner their own vWHM sign-in that manages only the accounts they own |
| Git deploys, cron jobs, SSH | Deploy from a repository, schedule tasks, shell access per account |
| Node.js, Python, Java | Managed apps and services under the account's own user |
| Apache Kafka and Redis | Per-account Kafka logins and ACLs; Redis for cache and sessions |
| One-click WordPress | Install and configure WordPress in one step |
| Security | 2FA, brute-force lockout, firewall with fail2ban, ModSecurity (OWASP CRS), virus scanner (ClamAV), audit log |
| PHP | Multiple PHP versions per account, per-server php.ini defaults, automatic PHP security patching |
| Updates | Daily check and self-install of new signed releases; security advisories shown in vWHM |

## Security and release integrity

Vanta Panel is proprietary software distributed as **signed releases**. The source code is not published in this repository: this repo holds the documentation and the installer only.

Every release is signed with an **Ed25519** key whose private half never leaves the release machine. The installer verifies that signature before anything is installed:

1. `update.json` is fetched over HTTPS.
2. The bundle's **SHA-256** is checked against the manifest.
3. A detached **Ed25519 signature** over `version|url|sha256` is verified against a public key **pinned in the installer itself**.

A SHA-256 alone only proves the download matches what the server said; whoever can serve you a modified bundle can serve a matching hash. The signature cannot be forged without the private key, so a tampered or substituted release **fails to install** rather than installing silently.

Release signing key (Ed25519, base64), as pinned in [`install/bootstrap.sh`](install/bootstrap.sh) and served at [get.vantapanel.com](https://get.vantapanel.com):

```
jregvMSJcKrLBL0IAx4gnrq3kFmdyIpR8JjhAi6dnJg=
```

Verify any release yourself before installing:

```bash
curl -fsSL https://get.vantapanel.com/update.json -o update.json
curl -fsSL https://get.vantapanel.com | sudo VP_BOOTSTRAP_ONLY=1 bash
```

`VP_BOOTSTRAP_ONLY=1` (set after `sudo`, so it reaches the installer) downloads and verifies the release, then stops without installing anything.

Security fixes are published as advisories at [vantapanel.com/security/advisories](https://vantapanel.com/security/advisories), with the versions affected and what to do. Found a security issue? See [SECURITY.md](SECURITY.md) and report it privately to **security@vantapanel.com** rather than opening a public issue.

## Why Vanta Panel

- **You own everything.** It runs on your server. The data, the accounts and root stay with you, and sites, mail and DNS keep serving even if a licence lapses.
- **No per-account fees.** $10 a month covers a server with ten customers or a thousand. Every feature is in every tier, including a real free tier.
- **Complete for selling hosting.** Mail, DNS, customer logins, resellers and WHMCS are built in, which is what most cheap cPanel replacements leave out.
- **Modern runtimes.** Node.js, Python, Java, Kafka and Redis next to PHP, a stack most legacy panels never grew into.

## What's in this repo

This repository is **documentation and the installer**, plus the issue tracker. The Vanta Panel application itself is proprietary, commercial software and its source is not published here. This repo is the public front door for reading the docs, running the one-command install, reporting bugs and following the project.

## Support and issues

Found a bug or have a question? [Open an issue](../../issues) on this repository, or email support@vantapanel.com.

---

Vanta Panel · self-hosted hosting control for servers you own · [vantapanel.com](https://vantapanel.com)
