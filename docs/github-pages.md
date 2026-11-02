# GitHub Pages for App Store URLs (wifyradar)

Host a public **Privacy Policy** and **Support** page on [GitHub Pages](https://docs.github.com/en/pages) so App Store Connect has HTTPS URLs. Marketing URL is optional and can point at the same site home page.

This path assumes a GitHub account already exists. Completing it supplies the URLs for [`app-store-checklist.md`](app-store-checklist.md) §3 (Privacy Policy) and §4 (Support URL).

**Why a separate public repo:** GitHub Pages on a free personal account needs a **public** repository. Keep the app source private; publish only the two HTML pages from a small public site repo.

**Identifiers**

| Item | Example |
|------|---------|
| Site repo name | `wifyradar-site` |
| GitHub username | replace `USERNAME` below with the GitHub username |
| Privacy Policy URL | `https://USERNAME.github.io/wifyradar-site/privacy.html` |
| Support URL | `https://USERNAME.github.io/wifyradar-site/` |

---

## 1. Create the public site repo

1. Open [GitHub](https://github.com) → **+** → **New repository**.
2. **Repository name:** `wifyradar-site` (any name works; it appears in the URL path).
3. **Public**.
4. Check **Add a README file**.
5. Create the repository.

**Done when:** the empty public repo exists on GitHub.

---

## 2. Add the two pages

In the repo on GitHub:

1. **Add file** → **Create new file**.
2. Name the file `index.html`. Paste a minimal support page (edit the email):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>wifyradar Support</title>
</head>
<body>
  <h1>wifyradar</h1>
  <p>Shared lists on iPhone via iCloud.</p>
  <p>Support: <a href="mailto:YOU@example.com">YOU@example.com</a></p>
  <p><a href="privacy.html">Privacy Policy</a></p>
</body>
</html>
```

3. Commit to the default branch (usually `main`).
4. **Add file** → **Create new file** → `privacy.html`. Paste a privacy page that covers at least:
   - List and item content stored in the user’s **iCloud** via **CloudKit**
   - Optional **Contacts** access: on-device invite email pick only; address book not uploaded
   - Invite email / participant identity for CloudKit sharing
   - How to stop sharing, leave a list, or delete data (in-app and via the user’s iCloud account)
5. Commit.

Minimal skeleton (replace bracketed text and expand before App Review):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>wifyradar Privacy Policy</title>
</head>
<body>
  <h1>wifyradar Privacy Policy</h1>
  <p>Last updated: [DATE]</p>
  <p>wifyradar stores list and item content in your iCloud account using Apple CloudKit. The developer does not operate a separate content server for that data.</p>
  <p>Sharing a list uses the invitee’s Apple ID email (and related CloudKit participant identity) so Apple can deliver the share. Contacts access is optional and used only on device to help pick that email; the address book is not uploaded.</p>
  <p>Stop sharing or leave a list in the app. Delete lists you own in the app, or manage iCloud data in iOS Settings under your Apple ID → iCloud.</p>
  <p>Contact: <a href="mailto:YOU@example.com">YOU@example.com</a></p>
  <p><a href="index.html">Support</a></p>
</body>
</html>
```

**Done when:** `index.html` and `privacy.html` are on the default branch.

---

## 3. Turn on GitHub Pages

1. Open the repo → **Settings** → **Pages** (under **Code and automation**).
2. **Build and deployment** → **Source:** **Deploy from a branch**.
3. **Branch:** `main` (or the default branch) → folder **/` (root)** → **Save**.
4. Wait one to two minutes. The Pages settings page shows the site URL when it is live.

**Done when:** visiting `https://USERNAME.github.io/wifyradar-site/` loads the support page over HTTPS, and `/privacy.html` loads the policy.

If the site 404s, confirm the repo is **Public**, the branch and `/ (root)` source match §3, and wait for the first deploy to finish.

---

## 4. Paste URLs into App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. **App Privacy** / privacy policy field (checklist §3): paste  
   `https://USERNAME.github.io/wifyradar-site/privacy.html`
3. App Store version → product page **Support URL** (checklist §4): paste  
   `https://USERNAME.github.io/wifyradar-site/`
4. Optional **Marketing URL:** same as Support, or omit.

**Done when:** both URLs open in a browser while signed out of GitHub, and the fields in App Store Connect are saved.

---

## 5. Later edits

Edit `index.html` or `privacy.html` on GitHub (or clone the repo and push). Pages updates after the commit deploys. Bump the policy “Last updated” date when the text changes in a material way.
