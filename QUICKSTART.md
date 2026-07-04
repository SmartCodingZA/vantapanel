# Vanta Panel — Quick Start

**Vanta Panel** is a self-hosted web hosting control panel you install on your own VPS — a modern alternative to cPanel/WHM. One install gives you two apps:

- **vWHM** (admin) at `https://<host>/vwhm` — create and manage hosting accounts, server status, licensing.
- **vPanel** (customer) at `https://<host>/vpanel` — sites, email, databases, DNS, SSL, and more.

Privileged actions are brokered through a narrow, audited `sudo` rule; the web tier runs unprivileged. You own the server and the data — no per-account fees.

> **Just looking?** Try the live demo at **https://demo.vantapanel.com** — vWHM login `demo`/`demo`, vPanel login `acme`/`demo`. It's read-only, resets hourly, and needs no signup.

> **About this repo:** this is the **docs + installer** for Vanta Panel. The panel itself is proprietary, commercial software and its source is not published here. This repo exists so you can read the docs, run the installer, file issues, and follow the project. The installer fetches the panel and sets it up for you.

---

## 1. Requirements

- A **fresh VPS** running **Ubuntu 22.04 LTS (or newer)** or **Debian 12 (or newer)**. Older releases ship PHP 7.x, which the panel does not support — the installer stops with a clear message if PHP is too old.
- **64-bit** CPU (x86_64 or arm64).
- **~2 GB RAM** and **~3 GB free disk** minimum.
- **Root access** (run the installer with `sudo`).
- **Nothing else already serving ports 80/443** — no existing nginx or Apache.

Open these ports at your VPS provider's firewall:

| Port(s) | Purpose |
|---|---|
| `80`, `443` | Panel + hosted websites |
| `22` | SSH |
| `25`, `587`, `465`, `143`, `993`, `110`, `995` | Mail (only if you use email) |

> Install on a **clean** server. The installer configures Apache, MariaDB, Postfix, Dovecot and more; mixing it with an existing web or mail stack is unsupported.

---

## 2. Install

One command, run as root:

```bash
curl -fsSL https://get.vantapanel.com | sudo bash
```

That's it. The installer:

1. Runs pre-flight checks — OS, PHP version, architecture, disk, and free ports.
2. Installs and configures the full stack (Apache, MariaDB, Postfix, Dovecot, PHP, and the panel).
3. Issues a self-signed certificate so the panel is reachable over HTTPS immediately.
4. Prints a banner with your **access URLs and admin login**.

It finishes in about **3 minutes**. The installer is **idempotent** — re-running it is safe and never resets your database password or admin account, so it's also how you upgrade later.

> **Save the banner.** When it finishes, the installer prints your access URLs and the admin credentials, and also writes them to `/root/vantapanel-install.txt` (root-only). Copy them somewhere safe.

---

## 3. First login

Open the admin panel in your browser:

```
https://<host>/vwhm
```

Replace `<host>` with your server's domain or public IP. On a fresh install with a self-signed certificate, your browser will warn on first visit — that's expected; continue through it (real SSL is one command away, see below).

Sign in with the **admin login** printed in the installer banner:

- **Username:** `admin`
- **Password:** a random password generated during install and shown in the banner (also saved to `/root/vantapanel-install.txt`).

That single login is all a default install needs — there is no second password to find.

> **Optional hardening:** if you want an extra HTTP Basic Auth prompt in front of `/vwhm`, install with `VANTAPANEL_WHM_GATE=1` set. This is **off by default** — most operators don't need it, and the panel already has its own login.

> **Re-running the installer** keeps your existing admin account untouched. To force a new admin password, set `ADMIN_PASS=yourpassword` before running the installer.

Once in vWHM, create your first hosting account — it gets its own `https://<host>/vpanel` login where its owner manages sites, email, and databases.

---

## 4. Point a domain and get real SSL

The self-signed certificate works but triggers browser warnings. To get a free, trusted certificate:

1. Point a domain's **A record** at your server's public IP.
2. Once DNS resolves, issue a certificate with certbot:

   ```bash
   sudo certbot --apache -d panel.yourdomain.com
   ```

Every hosting account you create can likewise get automatic free SSL for its own domains from inside vPanel.

---

## 5. Create your first hosting account

In **vWHM → Accounts**, create an account: choose a username, its primary domain, and a plan. That provisions an isolated Linux user with quotas, a `vPanel` login, and (per plan) email, databases, DNS, and the rest. Hand the account owner their `https://<host>/vpanel` URL and credentials, and they self-serve from there.

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Installer stops: *"Ubuntu/Debian required"* or *"PHP too old"* | You're on an unsupported OS. Reinstall the VPS with Ubuntu 22.04+ or Debian 12+. |
| Installer stops: *ports 80/443 in use* | Another web server (nginx/Apache) is running. Install on a clean server, or stop and remove the existing stack first. |
| Can't reach `/vwhm` after install | Check your VPS provider's firewall allows ports 80/443. Confirm you're using `https://` and the correct host/IP. |
| Browser certificate warning | Expected with the default self-signed cert. Continue through it, or issue a trusted cert with certbot (Section 4). |
| Lost the admin password | It's saved to `/root/vantapanel-install.txt`. To reset it, re-run the installer with `ADMIN_PASS=newpassword`. |

---

Need help? [Open an issue](../../issues) or see [vantapanel.com](https://vantapanel.com).
