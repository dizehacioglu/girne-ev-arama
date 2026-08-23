# Girne'de Ev Arama — kurulum

A single self-contained `index.html` — no build step, no framework, no
server code. Paste a listing's page source (or fill fields by hand), track
rent/rooms/bathrooms/lease length/status, tap to WhatsApp or call the
listing's number, favorite the best ones. Data lives in a free Supabase
Postgres table, so it's automatically available from any device — just
open the same hosted link on her phone and on your computer.

This replaces the earlier Google Apps Script version. The reason: Apps
Script's deployed app runs inside a sandboxed cross-origin iframe with no
real devtools access, and code changes require manually creating a new
deployment version or they silently don't take effect — both cost real
debugging time. This version is just a normal webpage: normal browser
console, redeploy = re-upload the file.

## 1. Create the database (~3 minutes)

1. Go to [supabase.com](https://supabase.com) and create a free account /
   sign in, then **New project**. Pick any name/region/password (the
   password is for direct Postgres access, not needed for this app — save
   it somewhere just in case).
2. Once the project is ready, open the **SQL Editor** (left sidebar) →
   **New query**, paste in the entire contents of `schema.sql` from this
   folder, and click **Run**. This creates the `ilanlar` table and the
   access policies.
3. Go to **Project Settings → API Keys**. Copy two values:
   - **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`) — this
     is on the main API settings page.
   - **Publishable key** (starts with `sb_publishable_...`). If you don't
     see one yet, there's a **Create new API Keys** button — click it, then
     copy the Publishable key value. This is Supabase's current
     recommended key for client-side apps like this one (it replaces the
     older "anon" key you may see referenced in older tutorials — same
     purpose, safe to put in a public page, same access rules).

## 2. Configure the app

Open `index.html` in this folder and find these two lines near the top of
the `<script>` block:

```js
var SUPABASE_URL = 'YOUR_SUPABASE_URL';
var SUPABASE_PUBLISHABLE_KEY = 'YOUR_SUPABASE_PUBLISHABLE_KEY';
```

Replace both placeholder strings with the values you copied. Save the
file. (If you forget this step, the app shows a clear on-page message
telling you what's missing instead of failing silently.)

## 3. Host it (pick one — the file doesn't care which)

**Option A — GitHub Pages** (you already run `dizehacioglu.github.io`, so
this is zero new infrastructure):
1. Create a new repo (or a folder in an existing Pages-enabled repo), add
   `index.html`.
2. Push it. In the repo's **Settings → Pages**, set the source branch —
   GitHub gives you a URL like `https://<you>.github.io/<repo>/`.
3. That URL is what you send to your mom and use yourself.

**Option B — Netlify Drop** (fastest, no git or account needed for a first
deploy):
1. Go to [app.netlify.com/drop](https://app.netlify.com/drop).
2. Drag this whole folder (or just `index.html`) onto the page.
3. Netlify gives you a live URL immediately. Create a free account if you
   want to keep the same URL for future re-uploads (drag the folder again
   any time you edit `index.html`).

Either way: whenever you edit `index.html`, redeploying is just "push" or
"drag the folder again" — no separate "create a new version" step to
forget.

## How auto-fill actually works

Both hangiev.com and 101evler.com sit behind Cloudflare bot-protection,
which blocks any automated fetch of the page — so the app can't just take a
URL and go get the listing itself. Instead, on a listing page:

Right-click → **"Sayfa Kaynağını Görüntüle" / "View Page Source"** (or
Ctrl+U), select all (Ctrl+A), copy (Ctrl+C), and paste into the app's
textarea. This is the real HTML of the page — since it's not a live fetch,
Cloudflare has nothing to block. From it, the app reads exact rent, rooms,
bathrooms, phone, title, the listing's own link, and its cover photo (for
the thumbnail) — all parsed right in the browser, no server involved at
all.

This only works from a desktop/laptop browser — mobile browsers don't have
an easy "view source" option, so this is a computer-only step.

**Manual entry fields only appear after she's pasted something** (pre-filled
with whatever was found, or empty if nothing was) — this keeps the
add-listing form from showing a big intimidating form up front. If she
doesn't have the page source for a listing, there's a small "veya elle
gir →" link that reveals the manual fields directly.

There's no URL field to type into — the listing's link is detected
automatically from the pasted source (via its `og:url`/canonical tag) and
used to make the listing's title clickable and to show its cover photo. If
nothing was pasted (manual entry only), the card just won't have a link or
thumbnail — still fully usable, contact info and everything else works.

## Security note

There's no login. The publishable key is public in the page's source by
design — that's how every client-only Supabase app works, and it's exactly
as safe to expose as the older "anon" key it replaces — and the policies in
`schema.sql` let anyone who has that key and your Project URL read and
write the `ilanlar` table. In practice that means: whoever has the hosted
link can see and edit the data (nobody else can find it without the link).
That's an acceptable trade-off for a rental search list that isn't
sensitive, but it's worth knowing plainly rather than assuming it's private
just because there's no visible login screen.

## Everything the app tracks per listing

- Auto-detected link to the original listing and a small cover-photo
  thumbnail (both only available when page source was pasted)
- Title (clickable, opens the original listing), neighborhood, rent +
  currency, rooms (e.g. 2+1), bathrooms, lease duration
- Owner's phone number, with one-tap **WhatsApp** (pre-filled "is this still
  available?" message in Turkish) and **Ara** (call) buttons
- Status: İletişime geçilecek → Yanıt bekleniyor → Ziyaret planlandı →
  Ziyaret edildi → Uygun değil (color-coded so the stage is visible at a
  glance)
- A scheduled visit date + time per listing, with a toggleable **Takvim**
  (calendar) view showing every upcoming visit across the month — click a
  visit in the calendar to jump straight to that listing in the list
- A toggleable **Harita** (map) view — every listing with detected
  coordinates plotted on an interactive map (via [Leaflet](https://leafletjs.com)
  + free OpenStreetMap tiles, loaded from a CDN, no API key or account
  needed), so it's obvious at a glance which listings are actually near each
  other. Click a pin to see its photo/title and jump straight to it in the list
- A star for favorites, independent of status
- A free-text note field
