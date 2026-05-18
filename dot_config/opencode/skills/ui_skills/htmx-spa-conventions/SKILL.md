---
name: htmx-spa-conventions
description: UI coding conventions for an HTMX + Alpine.js SPA stack with Tailwind CSS
license: MIT
compatibility: opencode
---

## What I do.
- Define the core HTMX SPA architecture: HTMX for dynamic content loading, Alpine.js for lightweight client-side interactions.
- Handle page transitions via HTMX AJAX swapping (`hx-get`, `hx-post`, `hx-target`) — no full page reloads.
- Keep HTML generation server-side; return partial HTML fragments for HTMX requests, not JSON.
- Enforce mobile-first responsive layouts with standard mobile utilities and `md:` desktop overrides.
- Use sticky bottom navigation or hamburger menus on mobile; traditional top/side navigation on desktop.
- Style with Tailwind CSS utility classes exclusively — no custom `<style>` blocks.
- Maintain a modern, professional, clean, minimal aesthetic with ample whitespace.
- Use a clean color palette: off-white/light gray backgrounds, dark charcoal text, a single accent color (indigo or emerald) used sparingly.
- Ensure all interactive elements have clear focus states (`focus:ring-2`).
- Use semantic HTML tags (`<nav>`, `<main>`, `<header>`, `<article>`) instead of nested `<div>` wrappers.

## When to use me.
Use this skill whenever building or modifying UI components, layouts, or page views in this project. It governs all frontend conventions — from component structure and styling to accessibility and responsiveness.
