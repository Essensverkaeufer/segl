# segl pet clicker

A tiny full-screen cat petting competition.

## Files needed

Put these in the repo root:

- `index.html`
- `segl.jpg`
- `segl.mp3`

The page stretches `segl.jpg` ugly/fullscreen with `object-fit: fill`.
Every click plays `segl.mp3`.

## Supabase

The database migration has already been applied to the `haustierapp` Supabase project.

Created separate objects:

- `public.segl_players`
- `public.segl_register`
- `public.segl_login`
- `public.segl_pet`
- `public.segl_get_salt`
- `public.segl_leaderboard`

It does not touch the old Haustier-App tables.

## Important

In `index.html`, replace:

```js
const SUPABASE_KEY = "PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE";
```

with the Supabase publishable/anon key from:

Supabase Dashboard -> Project Settings -> API -> Project API keys

The project URL is already set:

```js
const SUPABASE_URL = "https://yrcodmwahedzifumawjq.supabase.co";
```

## GitHub Pages

After uploading files to `Essensverkaeufer/segl`:

Settings -> Pages -> Deploy from branch -> `main` -> `/root`
