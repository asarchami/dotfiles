---
name: organize-media
description: Organize downloaded movies, TV series, and music on a homeserver into Emby-ready directory structure. Enriches music with proper ID3 tags via MusicBrainz and converts FLAC to MP3 V0.
---

## Source & Destination

| Source | Destination | Category |
|---|---|---|
| `~/storage/downloads/complete/Movies/` | `~/storage/media/movies/` | Movies |
| `~/storage/downloads/complete/Series/` | `~/storage/media/tv/` | TV Shows |
| `~/storage/downloads/complete/Music/` | `~/storage/media/music/` | Music |

Server: `ali@192.168.68.111`

## Workflow

### 0. Prerequisites

- `mutagen` — already available in Alpine system Python
- `ffmpeg` with `libmp3lame` — needed for FLAC→MP3 conversion

### 1. Connect

SSH into the homeserver.

### 2. Discover — Movies

List items in `~/storage/downloads/complete/Movies/`. Items are either `.mkv` files or directories containing a `.mkv` (torrent leftovers).

For each item, determine:
- **Title** — Use your knowledge of the actual movie title. Convert dots to spaces, handle Roman numerals (`II`, `III`), subtitles (`Dead Reckoning Part One`), and proper capitalization.
- **Year** — Extract the 4-digit year from the filename (range 1900–2029).
- **Destination** — `~/storage/media/movies/{Title} ({Year})/`
- **Exists?** — Check if destination directory already exists.

### 3. Discover — Series

List items in `~/storage/downloads/complete/Series/`. Source items can come in several shapes:

| Shape | Example | What to do |
|---|---|---|
| **Show dir with season subdirs** | `Show Name/Season 01/episode.mkv` | Already organized — merge season dirs into destination show |
| **Flat episode files** | `Show.Name.S01E01.Episode.Title.1080p.GROUP.mkv` | Parse show name + S##E## from filename. Create `Show Name/Season ##/` at destination |
| **Season pack dir** | `Show.Name.S01.Complete.1080p.GROUP/` | Parse show name + season from dir name. Move contents into `Show Name/Season ##/` |
| **Show dir with flat episodes** | `Show Name/Show.Name.S01E01.episode.mkv` | Parse season from filename. Create season subdir at destination. |

**Parsing episode filenames:**
- Extract: `Show Name` (you know actual TV show titles), `S##E##` (season/episode numbers), optional episode title
- Common patterns: `Show.Name.S01E01`, `Show.Name.Season.01.Episode.01`, `Show Name - S01E01`
- Season is always `S` followed by 1-2 digits
- Episode is always `E` followed by 1-2 digits

**Destination:** `~/storage/media/tv/{Show Name}/Season {##}/` — merge into existing if the show already has metadata/artwork. Create a new show directory if it doesn't exist.

### 4. Discover — Music

Walk `~/storage/downloads/complete/Music/` to discover all artist/album/track trees. Each artist is a directory, each album is a subdirectory, tracks are files inside.

For each track file, determine:
- **Format** — `.mp3` or `.flac`
- **Artist** — parent directory name (already clean, e.g. `Evanescence`)
- **Album** — album directory name. May be messy (e.g. `Megadeth - Megadeth 2026 WEB 24bit 48kHz [FLAC]`). Use MusicBrainz API to resolve the proper album name.
- **Track #** — number from filename (e.g. `01` from `01. Sweet Sacrifice.mp3`)
- **Title** — track title from filename
- **Year** — from MusicBrainz lookup (query by artist + album)
- **Genre** — from MusicBrainz tags
- **Cover art** — `cover.jpg` in album directory

MusicBrainz API endpoint: `https://musicbrainz.org/ws/2/release/?query=artist:{ARTIST}+release:{ALBUM}&fmt=json`
Use `inc=recordings` to get track listing, `inc=tags` for genre.

**MusicBrainz notes:**
- API is slow — 1-3s per query. Rate-limit to ~1 req/s. Do all lookups upfront and batch the results before starting any file operations.
- Some albums return no genre tags. Fall back to your knowledge of the artist's genre.
- If the exact album isn't found, broaden the search to `artist:{ARTIST}` and match by year manually.
- The "Fallen (2023 Version)" type of reissues may not resolve on MusicBrainz. Use the directory name as-is when the lookup fails.

**Path handling notes:**
- Album directories may contain `[brackets]`, `(parentheses)`, or spaces. Python `glob.glob()` interprets `[]` as character classes — use `os.listdir()` + `os.path.isdir()` instead.
- Source filenames use different track separator styles: `##. Title`, `## - Title`, `##–Title`. Handle all three.
- Cover art files vary in case: `cover.jpg`, `Cover.jpg`, `cover.jpeg`, `folder.jpg`. Check case-insensitively.
- Only clean up album subdirectories after moving their contents. Never remove parent artist directories or the top-level `Music/` directory.

### 5. Build Preview Table

Present a mapping to the user:

```
Movies (n new, m existing)
────────────────────────────────────────────
  Dune.2021.1080p...mkv      → Dune (2021)/
  Dust.Bunny.2025...mkv      ⚠ Already exists

Series (n shows — m organized, p parsed)
────────────────────────────────────────────
  Rick and Morty/Season 9/        → tv/Rick and Morty/Season 9/  [merge existing]
  Show.Name.S01E02.Episode.mkv   → tv/Show Name/Season 01/      [parse filename]
  Show.Name.S01.Complete/         → tv/Show Name/Season 01/      [parse dir name]

Music (n tracks — x MP3, y FLAC)
────────────────────────────────────────────
  Evanescence/The Open Door/01. Sweet Sacrifice.mp3  → OK [tagged]
  Megadeth/Megadeth/01. Tipping Point.flac           → CONVERT + tag
  Suede/Antidepressants (2025)/01. Disintegrate.flac → CONVERT + tag
```

Use clear status indicators (new / exists / empty / convert).

### 6. Confirm

Ask the user to confirm. If approved:

**Movies:**
- New: `mkdir -p` destination, `mv` file(s) in.
- Existing: Ask "`{Movie}` already in destination. Delete source? [y/N]" for each.

**Series:**
- **Already organized** (`Show/Season/`): `mv` season dirs into the show's destination. Merge into existing if show already has metadata.
- **Flat files** (`Show.Name.S01E01.episode.mkv`): Create `Show Name/Season 01/` at destination, `mv` file in. Use your knowledge of actual show names.
- **Season packs** (`Show.Name.S01.Complete/`): Create `Show Name/Season 01/` at destination, `mv` contents in.

**Cleanup rule for all categories:** After moving all content out of a source subdirectory (movie dir, season dir, album dir), remove that empty subdirectory. Never remove the top-level category directory (`Movies/`, `Series/`, `Music/`).

**Music (per album):**
1. **Convert** FLAC → MP3 V0: `ffmpeg -i input.flac -c:a libmp3lame -q:a 0 output.mp3`. Remove original `.flac` on success. Existing MP3s skip this step. Cover art is carried over automatically by ffmpeg.
2. **Write ID3v2 tags** with `mutagen` on every MP3:
   - `TIT2` (Title), `TPE1` (Artist), `TALB` (Album), `TDRC` (Year), `TCON` (Genre), `TRCK` (Track#), `TPE2` (Album Artist)
   - Embed cover art from `cover.jpg` into each file (`APIC` frame — stored as `APIC:Cover` in mutagen)
3. **Move** to `~/storage/media/music/{Artist}/{Album}/{##}. {Title}.mp3`
4. **Cleanup**: Remove the now-empty album subdirectory. Do **not** remove the artist directory or the `Music/` category directory.

All moves use `mv` (instant on same filesystem).

### 7. Verify

Confirm files landed correctly with `ls`. Report any unprocessed items.
- Movies: spot-check a few new directories.
- Series: confirm season dirs merged.
- Music: check tags on a few moved files with mutagen.

## Rules

**Movies & Series:**
- Do **not** modify video files — preserve original filenames exactly.
- Destination naming convention: `Title (Year)` with spaces. Use ` - ` for franchise/subtitle separators (e.g. `Mission - Impossible - Dead Reckoning Part One (2023)`).
- Use your knowledge of actual movie titles, not mechanical replace.
- TV show destinations may already have posters, nfo, artwork — never touch those.

**Music:**
- FLAC must be converted to MP3 V0. Remove the original `.flac` after successful conversion. Existing MP3s stay as-is.
- Write ID3v2 tags from directory hierarchy + MusicBrainz enrichment.
- Embed cover art from `cover.jpg` into each MP3 (`APIC` frame keyed as `APIC:Cover` in mutagen).
- Preserve original track filenames (including `##. ` prefix).
- MusicBrainz resolves messy album directory names. Use proper album names for destination directories.
- Destination structure: `music/{Artist}/{Album}/{##}. {Title}.mp3` — no year in directory name (year goes in ID3 tag).
- After moving all files from an album subdirectory, remove that empty subdirectory. Do **not** remove the artist directory or the top-level `Music/` category directory.
