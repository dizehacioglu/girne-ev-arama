# Girne'de Ev Arama

A single self-contained `index.html` — no build step, no framework, no
server code — for tracking apartment listings while hunting for a rental in
Girne (Kyrenia), Cyprus. Paste a listing's page source (or fill fields by
hand), track rent/rooms/bathrooms/lease length/status, tap to WhatsApp or
call the listing's number, favorite the best ones, schedule visits on a
calendar, and see everything plotted on a map. Data lives in a free
Supabase Postgres table, so it stays in sync across every device you open
the link on.

## Features

- Paste a listing's page source and auto-fill rent, rooms, bathrooms,
  phone, title, a link back to the original listing, and its cover photo
  (see "How auto-fill works" below) — or skip that and fill fields by hand
- Everything is editable inline in the table at any time
- Status pipeline — İletişime geçilecek → Yanıt bekleniyor → Ziyaret
  planlandı → Ziyaret edildi → Uygun değil — color-coded so the stage is
  visible at a glance
- One-tap **WhatsApp** (pre-filled "is this still available?" message in
  Turkish) and **Ara** (call) buttons
- A star for favorites, independent of status, and a free-text note field
- A toggleable **Takvim** (calendar) view showing every scheduled visit
  across the month, color-coded by status — click a visit to jump straight
  to that listing in the list
- A toggleable **Harita** (map) view — every listing with known coordinates
  plotted on an interactive map (via [Leaflet](https://leafletjs.com) +
  free OpenStreetMap tiles, no API key needed), pins color-coded by status,
  so it's obvious at a glance which listings are near each other. Click a
  pin to jump straight to it in the list
- Listings marked "Uygun değil" collapse out of the main list view by
  default (and off the map), but their calendar visits still show
- Responsive: a normal table on desktop, a stack of cards on mobile

## Setup

1. **Create the database** — go to [supabase.com](https://supabase.com),
   create a free project, open the **SQL Editor**, paste in the contents of
   `schema.sql`, and run it. This creates the `ilanlar` table and its
   access policies.
2. **Configure the app** — open `index.html`, find these two lines near the
   top of the `<script>` block, and fill in your own project's values from
   **Project Settings → API Keys** (the **Publishable key**, not the
   secret one):
   ```js
   var SUPABASE_URL = 'YOUR_SUPABASE_URL';
   var SUPABASE_PUBLISHABLE_KEY = 'YOUR_SUPABASE_PUBLISHABLE_KEY';
   ```
   If you forget this step, the app shows an on-page message telling you
   what's missing instead of failing silently.
3. **Host it** — this is a static file, so any static host works (GitHub
   Pages, Netlify, Vercel, Cloudflare Pages, etc.). Whenever you edit
   `index.html`, redeploying is just re-uploading the file — no build step,
   no "create a new version" step to remember.

## How auto-fill actually works

Real-estate listing sites commonly sit behind bot-protection that blocks
automated fetching, so the app can't just take a URL and go get the
listing itself. Instead, on a listing page:

Right-click → **"View Page Source"** (or Ctrl+U / Cmd+Option+U), select all,
copy, and paste into the app's textarea. This is the real HTML of the page
— since it's not a live fetch, bot-protection has nothing to block. From
it, the app reads rent, rooms, bathrooms, phone, title, the listing's own
link, its cover photo, and coordinates when present — all parsed entirely
in the browser, no server involved.

This only works from a desktop/laptop browser — mobile browsers don't have
an easy "view source" option, so it's a computer-only step. There's no URL
field to type into; the listing's link is detected automatically from the
pasted source (via its `og:url`/canonical tag) and used to make the
listing's title clickable and to show its cover photo.

The parsing logic targets the HTML structure of specific listing sites
(currently hangiev.com and 101evler.com) — pasting source from a different
site may fill in fewer fields, or none. Either way, nothing is required
before saving: an entry is created immediately from whatever was found (or
blank), and every field stays editable afterward.

## Security note

There's no login. The publishable key is public in the page's source by
design — that's how every client-only Supabase app works — and the
policies in `schema.sql` let anyone who has that key and your Project URL
read and write the `ilanlar` table. In practice that means: whoever has the
hosted link can see and edit the data (nobody else can find it without the
link). That's an acceptable trade-off for a rental search list that isn't
sensitive, but it's worth knowing plainly rather than assuming it's private
just because there's no visible login screen.
