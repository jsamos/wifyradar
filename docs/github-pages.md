# GitHub Pages for App Store URLs (wifyradar)

Host a public **Privacy Policy** and **Support** page on [GitHub Pages](https://docs.github.com/en/pages) so App Store Connect has HTTPS URLs. Marketing URL is optional and can point at the same site home page.

Page source of truth in this repo: [`docs/site/`](site/) (`index.html`, `privacy.html`, `styles.css`). Completing this path supplies the URLs for [`app-store-checklist.md`](app-store-checklist.md) §3 (Privacy Policy) and §4 (Support URL).

This path assumes a GitHub account already exists.

**Why a separate public repo:** GitHub Pages on a free personal account needs a **public** repository. Keep the app source private; copy only the files under `docs/site/` into a small public site repo.

**Identifiers**

| Item | Value |
|------|--------|
| Site repo name | `wifyradar-site` |
| GitHub username | `chipinhead` |
| Privacy Policy URL | https://chipinhead.github.io/wifyradar-site/privacy.html |
| Support URL | https://chipinhead.github.io/wifyradar-site/ |
| Support email | `admin@vesenterprises.com` |

---

## 1. Create the public site repo

1. Open [GitHub](https://github.com) → **+** → **New repository**.
2. **Repository name:** `wifyradar-site` (any name works; it appears in the URL path).
3. **Public**.
4. **Add a README file** is optional (handy on the repo home page; not required for the site).
5. Create the repository.

**Done when:** the public repo exists on GitHub.

---

## 2. Upload the pages on github.com

Use the GitHub website so no local git commands are required. Upload the three files into the **root** of `wifyradar-site` (not inside a folder).

1. On this Mac, open the app repo folder → [`docs/site/`](site/). Note these three files: `index.html`, `privacy.html`, `styles.css`.
2. In the browser, open the **wifyradar-site** repo on GitHub.
3. **Add file** → **Upload files**.
4. Drag all three files into the upload area (or choose them with the file picker).
5. Confirm the preview lists `index.html`, `privacy.html`, and `styles.css` at the repo root (paths must not look like `docs/site/…`).
6. Commit message: for example `Add support and privacy pages`.
7. **Commit changes** (commit directly to the default branch, usually `main`).

**Done when:** the repo file list shows those three files at the top level of `wifyradar-site`.

---

## 3. Turn on GitHub Pages

1. Open the site repo → **Settings** → **Pages** (under **Code and automation**).
2. **Build and deployment** → **Source:** **Deploy from a branch**.
3. **Branch:** `main` (or the default branch) → folder **/ (root)** → **Save**.
4. Wait one to two minutes. The Pages settings page shows the site URL when it is live.

**Done when:** visiting https://chipinhead.github.io/wifyradar-site/ loads the support page over HTTPS, and https://chipinhead.github.io/wifyradar-site/privacy.html loads the policy.

If the site 404s, confirm the repo is **Public**, the branch and `/ (root)` source match §3, and wait for the first deploy to finish.

---

## 4. Paste URLs into App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **wifyradar**.
2. **App Privacy** / privacy policy field (checklist §3): paste  
   https://chipinhead.github.io/wifyradar-site/privacy.html  
   If App Store Connect shows **Publish**, click it. That publishes App Privacy / the policy URL on the product page; it is not submitting the app for App Review.
3. Open **Distribution** → **iOS App** → **1.0 Prepare for Submission**. Scroll to **Support URL** and paste  
   https://chipinhead.github.io/wifyradar-site/  
   then **Save**. Other product-page fields (description, keywords, screenshots) are covered in [`app-store-checklist.md`](app-store-checklist.md) §4.
4. Optional **Marketing URL:** same as Support, or omit.

**Done when:** both URLs open in a browser while signed out of GitHub, Privacy Policy is set in App Privacy, and **Support URL** is saved on the version page.

---

## 5. Later edits

1. Edit the files under [`docs/site/`](site/) in the app repo (source of truth).
2. On github.com → **wifyradar-site** → open each changed file → pencil **Edit** → paste the new contents → commit; or **Add file → Upload files** again to replace files with the same names.
3. Bump the policy “Last updated” date when the text changes in a material way.
