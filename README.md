# 0xBURGER

> Grill bytes, not beef.

Welcome to the official 0xBURGER website: a fast, neon-diner command center for a Malaysian CTF crew that likes clean exploits, readable notes, and flags plated with style.

[Live site](https://0xburger.netlify.app) | [CTFtime](https://ctftime.org/team/440041) | [LinkedIn](https://www.linkedin.com/company/109648831/) | [GitHub](https://github.com/0xburger)

## What Is This?

0xBURGER is a themed CTF team site with a playful terminal UI, animated burger-stack interactions, team roster, kitchen/tooling section, and writeup archive area.

It is built as a static frontend so it can deploy cleanly to Netlify, Cloudflare Pages, GitHub Pages, or any boring static host that knows how to serve HTML, CSS, and JavaScript.

## Highlights

- Interactive terminal-style homepage with burger-flavored commands
- Animated CTF team profile and live-feeling stats area
- Crew roster, capability cards, and writeup archive sections
- Security-conscious Netlify headers via `_headers`
- Optional Supabase admin/CMS flow kept behind an ignored `admin-config.json`
- Public flag checker integration for CTF-style hidden challenges

## Burger Stack

```text
        .-===========-.
     .-'  sesame ops  '-.
   /__  crypto cheese  __\
   \  reversing lettuce  /
    |   web tomato     |
    |   pwn patty      |
     \__ bottom bun __/

        0xBURGER
```

## Project Structure

```text
.
|-- assets/
|   |-- app.js
|   `-- styles.css
|-- docs/
|-- netlify/
|-- scripts/
|   `-- build-static.js
|-- supabase/
|-- _headers
|-- admin-config.example.json
|-- index.html
|-- netlify.toml
|-- package.json
|-- provision_admin.py
`-- supabase-setup.sql
```

## Run Locally

No framework ceremony. A static server is enough:

```bash
npx serve .
```

Or with Python:

```bash
python -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

## Build

```bash
npm install
npm run build
```

The static build output is written to:

```text
dist/
```

## Deploy

### Netlify

This repo includes `netlify.toml` and `_headers`, so Netlify can serve the site with the intended security headers.

### Cloudflare Pages

```bash
npm run deploy:pages
```

## Optional Admin Config

Admin editing uses Supabase only when a private local config exists:

```text
admin-config.json
```

Start from:

```text
admin-config.example.json
```

That real config is intentionally ignored by Git. Do not deploy real Supabase keys or private admin config into a public static site.

## Security Notes

The site is static-first and ships with a restrictive baseline:

- `Content-Security-Policy`
- `Strict-Transport-Security`
- `Referrer-Policy`
- `Permissions-Policy`
- `X-Content-Type-Options`

The browser is not a secret vault. Anything placed in public HTML, CSS, or JS should be considered visible to players and visitors.

## Team Flavor

0xBURGER keeps the theme silly and the workflow serious:

- Reproduce the solve
- Document the root cause
- Disclose responsibly
- Ship the writeup after the round

Flags are plated, not sprayed.
