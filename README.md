# Vanta Panel

**A self-hosted web hosting control panel for your own VPS — a modern alternative to cPanel/WHM.**

[![Version](https://img.shields.io/badge/version-5.40-2b7fff)](https://vantapanel.com)
[![License](https://img.shields.io/badge/license-proprietary-lightgrey)](https://vantapanel.com)
[![Self-hosted](https://img.shields.io/badge/self--hosted-yes-brightgreen)](https://vantapanel.com)
[![Install](https://img.shields.io/badge/install-one%20command-blueviolet)](https://get.vantapanel.com)

Vanta Panel installs on a VPS you own and turns it into a full hosting platform: hosting accounts, domains, email, databases, DNS, SSL, and modern runtimes like Java, Kafka, and Redis — administered through two clean web apps. You keep the server, the data, and root. There are no per-account fees.

One install gives you both apps:

- **vWHM** — the admin console, at `https://<host>/vwhm`
- **vPanel** — the customer control panel, at `https://<host>/vpanel`

## Install

```bash
curl -fsSL https://get.vantapanel.com | sudo bash
```

**Requirements:** a fresh Ubuntu 22.04+ or Debian 12+ server, 64-bit, ~2 GB RAM, ~3 GB disk, root access, and nothing already bound to ports 80/443. Installs in about three minutes.

## Try the live demo

No signup, no install — poke at a real running instance.

**Demo:** [demo.vantapanel.com](https://demo.vantapanel.com) — read-only, resets hourly.

| App | URL | Login |
| --- | --- | --- |
| vWHM (admin) | [demo.vantapanel.com/vwhm](https://demo.vantapanel.com/vwhm) | `demo` / `demo` |
| vPanel (customer) | [demo.vantapanel.com/vpanel](https://demo.vantapanel.com/vpanel) | `acme` / `demo` |

## Features

Every service below is built in, and every one is available in every plan.

| Service | What it does |
| --- | --- |
| Hosting accounts | Isolated Linux users with disk quotas |
| Domains & subdomains | Add, park, and route domains |
| Email & webmail | Mailboxes, forwarders, and browser webmail |
| MySQL databases | Databases and users, with phpMyAdmin |
| Free SSL | Automatic HTTPS via Let's Encrypt |
| DNS zone editor | Full zone control, with optional Cloudflare integration |
| File manager | Browse, edit, and upload over the web |
| Cron jobs | Scheduled tasks per account |
| Backups | Scheduled and on-demand backups |
| Git deploys | Deploy sites straight from a Git repository |
| Java apps | Run `.jar` files as managed services |
| Apache Kafka | Per-account brokers with SCRAM auth and ACLs |
| Redis | Per-account Redis instances |
| SSH access | Direct shell access for accounts |
| Security suite | 2FA, IP blocker, and hotlink protection |
| One-click WordPress | Install and configure WordPress in one step |
| Metrics & logs | Resource usage and log viewing |
| Per-user PHP isolation | Each account runs under its own PHP-FPM pool and Linux user |
| cPanel migration | Import a `cpmove` archive: sites, databases, mail, and cron |
| Remote backups | Push backups to S3-compatible storage, FTP/FTPS, or SFTP |
| Automatic updates | Daily check and self-install of new signed releases |
| Python apps | Managed virtualenv apps served by uvicorn/gunicorn |
| Mail filters & autoresponders | Per-mailbox Sieve rules, vacation replies, and mailing lists |

## Security & release integrity

Vanta Panel is proprietary software distributed as **signed releases**. The source
code is not published in this repository — this repo holds the documentation and
the installer only.

Every release is signed with an **Ed25519** key whose private half never leaves the
release machine. Both the installer and the panel's built-in updater verify that
signature before anything is installed:

1. `update.json` is fetched over HTTPS.
2. The bundle's **SHA-256** is checked against the manifest.
3. A detached **Ed25519 signature** over `version|url|sha256` is verified against a
   public key **pinned in the installer itself**.

Step 3 is what matters. A SHA-256 alone only proves the download matches what the
server said — whoever can serve you a modified bundle can serve a matching hash.
The signature cannot be forged without the private key, so a tampered or
substituted release **fails to install** rather than installing silently.

Release signing key (Ed25519, base64):

```
2g950+0wsBM3kjfr437q80GCYqM38BKvCpP6beZ6eRk=
```

You can verify any release yourself before installing:

```bash
curl -fsSL https://get.vantapanel.com/update.json -o update.json
VP_BOOTSTRAP_ONLY=1 curl -fsSL https://get.vantapanel.com | sudo bash
```

`VP_BOOTSTRAP_ONLY=1` downloads and verifies the release, then stops without
installing anything.

Found a security issue? See [SECURITY.md](SECURITY.md) — please report privately
to **security@vantapanel.com** rather than opening a public issue.

## Why Vanta Panel

- **You own everything.** It runs on your server. The data, the accounts, and root all stay with you — nothing phones home to a third party for the things that matter.
- **No per-account fees.** Plans price on headroom, not on how many customers you host. Every feature is in every tier, including a real free tier.
- **Modern runtimes.** First-class Java (`.jar` as a service), Apache Kafka, and Redis — a stack most legacy panels never grew into.
- **Two focused apps.** A dedicated admin console (vWHM) and a clean customer panel (vPanel), instead of one sprawling interface.

Coming from cPanel/WHM, the model is familiar — admin app plus per-account app — but you buy capacity instead of paying per account, and the runtime story goes well beyond PHP.

## What's in this repo

This repository is **documentation and the installer** — plus the issue tracker. The Vanta Panel application itself is proprietary, commercial software and its source is not published here. That is by design; this repo is the public front door for reading the docs, running the one-command install, reporting bugs, and following the project.

## Links

- **Website:** [vantapanel.com](https://vantapanel.com)
- **Install endpoint:** [get.vantapanel.com](https://get.vantapanel.com)
- **Live demo:** [demo.vantapanel.com](https://demo.vantapanel.com)
- **Pricing:** Free `$0` · Starter `$5/mo` · Growth `$8/mo` · Unlimited `$10/mo` — see [vantapanel.com](https://vantapanel.com)

## Support & issues

Found a bug or have a question? [Open an issue](../../issues) on this repository.

---

Vanta Panel · self-hosted hosting control for servers you own · [vantapanel.com](https://vantapanel.com)
