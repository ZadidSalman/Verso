# Verso — Production Design System
### "Sage & Vellum" · Material You 3 · Flutter · Android-Only
### Version 1.0 — Complete UI/UX Specification

> **What this file is:** The single source of truth for every visual decision in Verso.
> Feed it to your AI coding assistant at the start of every session.
> Every measurement is in logical pixels (dp). Every colour is an `AppColors` token.
> Every animation has a named ID (A01–A30) with a ready-to-paste Flutter snippet.
> No hardcoded hex values, no inline font sizes, no arbitrary spacing — ever.

---

## ⚡ QUICK START — READ THIS FIRST

Before writing a single widget, answer these five questions:

| # | Question | Where to look |
|---|---|---|
| 1 | Which screen am I building? | Part 4 → Screen XX |
| 2 | Which background type does it use? | Screen spec → `Background: BG-XX` → Section 1.7 |
| 3 | Which Part 3 components appear in it? | Screen spec → component names |
| 4 | Which animations are referenced? | Screen spec → `A-XX` IDs → Section 2.3 |
| 5 | What are the exact UI copy strings? | `knowledge.md` → relevant screen section |

**Then build in this exact order — never skip steps:**

```
① Scaffold + background (BG-XX from Section 1.7)
② AppBar — only if the screen spec includes one
③ Content area — implement top-to-bottom, matching the grid layout exactly
④ Bottom navigation bar or sticky input bar
⑤ Tap handlers and navigation (context.go / context.push — never Navigator.push)
⑥ Animations — add only AFTER the layout looks correct
⑦ Semantics() wrappers on every interactive element (48×48dp minimum touch target)
⑧ Reduced-motion check — set MediaQuery.disableAnimations = true and verify it still works
```

---

## 📋 DOCUMENT MAP

```
PART 1 — FOUNDATIONS       Colours · Typography · Spacing · Shapes · Elevation · Backgrounds
PART 2 — ANIMATION SYSTEM  Constants · 30 named animations (A01–A30) · Reduced motion rules
PART 3 — COMPONENT LIBRARY 17 reusable components with complete Flutter implementation snippets
PART 4 — ALL SCREENS       25 screens with pixel-precise ASCII grid layouts (Screen 01–25)
PART 5 — FLUTTER THEME     Complete ThemeData — copy and paste directly into app_theme.dart
PART 6 — AI CODING PROMPT  Master prompt to prepend at the start of every AI coding session
```

---

# PART 1 — FOUNDATIONS

---

## 1.1 Design Philosophy

Verso is a **literary sanctuary**. The design should feel like holding a beautifully made journal — thick cream pages, sage-green cloth covers, and generous margins that invite you to write. Every visual decision flows from this metaphor.

**Three laws:**
1. **The page breathes** — whitespace is content. Crowding kills poetry.
2. **Motion has meaning** — animations communicate state changes. Nothing decorative.
3. **Text is the hero** — UI chrome steps back. The words lead.

**Material You 3 principles applied:**
- Fixed sage colour seed — no system dynamic colour override
- Tonal elevation instead of drop shadows
- Expressive rounded shapes that feel warm, not corporate
- Filled and outlined button pair — filled for primary action, outlined for secondary

**What this means in practice — concrete decisions:**

| Situation | Correct choice | Wrong choice |
|---|---|---|
| Empty state | Write a poetic sentence from knowledge.md | "No results found" |
| Card background | Surface (`#F6FAF8`) — barely there | White or grey card |
| Error message | Gentle, human copy | "Error 422" or "Something went wrong" |
| Icon + label gap | 4dp (space1) | Any arbitrary value |
| List of > 3 items | `ListView.builder` | `Column + .map()` |
| Remote image | `CachedNetworkImage` + blurhash | `Image.network()` |
| Elevation | Tonal colour tint | Drop shadow |

---

## 1.2 Colour Palette — Complete System

All values defined in `lib/core/theme/app_colors.dart` as `static const Color`.
Never reference hex directly in widgets. Use `AppColors.xxx` everywhere.

> **Common mistake:** Reaching for `Colors.grey` or `Colors.white` for backgrounds or text.
> Verso has its own off-white and grey tokens — always use those instead.
> `AppColors.surface` ≠ white. `AppColors.onSurfaceVariant` ≠ grey.

### Primary Family — Deep Sage Teal

```
Primary             #1F6B5A     RGB(31,107,90)
  Use on: FilledButton bg, FAB bg, active NavBar indicator,
          active tab text, links, focused border, cursor

Primary Container   #A8DACC     RGB(168,218,204)
  Use on: Active filter chip bg, selected card tint,
          NavBar pill indicator, badge bg

On Primary          #FFFFFF
  Use on: Text/icons placed on Primary bg

On Primary Cont.    #00201A     RGB(0,32,26)
  Use on: Text/icons placed on Primary Container bg
```

### Secondary Family — Forest Sage

```
Secondary           #4A7C59     RGB(74,124,89)
  Use on: Secondary action buttons, story card accents,
          progress bar fill (challengee side in duels)

Secondary Container #C1E8C8     RGB(193,232,200)
  Use on: Mood chip bg (default), tag chips, highlight backgrounds,
          "Following" feed filter active

On Secondary        #FFFFFF
On Secondary Cont.  #0B2112     RGB(11,33,18)
```

### Tertiary Family — Muted Sage Grey

```
Tertiary            #6B7B6E     RGB(107,123,110)
  Use on: Timestamps, metadata text, read-count icons,
          secondary stat numbers on profile

Tertiary Container  #DDE8DE     RGB(221,232,222)
  Use on: Language chips (EN/BN badge), divider bg,
          disabled chip background

On Tertiary         #FFFFFF
On Tertiary Cont.   #1A2B1D     RGB(26,43,29)
```

### Surface Family — Vellum White

```
Surface             #F6FAF8     RGB(246,250,248)
  Use on: Card backgrounds, bottom sheet bg, NavBar bg,
          AppBar bg, Scaffold background

Surface Variant     #EDF4F0     RGB(237,244,240)
  Use on: ThoughtCard bg, Message thread bg,
          alternate row bg, input field resting bg

On Surface          #1A1C1A     RGB(26,28,26)
  Use on: All primary body text, titles on surface

On Surface Variant  #404944     RGB(64,73,68)
  Use on: Secondary text, captions, placeholder text,
          inactive icons, read-count numbers

Background          #F6FAF8     (same as Surface)
Outline             #8FA89A     RGB(143,168,154) — borders, inactive nav icons
Outline Variant     #D8E5DC     RGB(216,229,220) — skeleton loaders, subtle separators
```

### Semantic Colours

```
Error               #B3261E     RGB(179,38,30)
Error Container     #F9DEDC     RGB(249,222,220)
Inverse Surface     #2A312D     RGB(42,49,45)   — snackbar/toast bg
Inverse On Surface  #EDF4F0     RGB(237,244,240) — snackbar/toast text
Success (non-M3)    #16A34A     RGB(22,163,74)   — "Live" pill, verified states
```

### Mood Accent Palette

Used ONLY as: card left-border (3dp, 80% opacity), chip text colour.
NEVER as a background fill on any card, sheet, or surface.

```
Melancholic    #6366F1    Indigo   — introspection, quiet sadness
Romantic       #EC4899    Pink     — love, longing, desire
Joyful         #F59E0B    Amber    — celebration, lightness, warmth
Angry          #EF4444    Red      — protest, urgency, fire
Peaceful       #1F6B5A    Sage     — calm, nature, stillness (matches Primary)
Nostalgic      #8B5CF6    Violet   — memory, longing for the past
Mysterious     #1F2937    Charcoal — enigma, dark, unknowing
Spiritual      #D97706    Gold     — sacred, transcendent, divine
```

```dart
// lib/core/theme/app_colors.dart — full implementation
class AppColors {
  static const primary             = Color(0xFF1F6B5A);
  static const primaryContainer    = Color(0xFFA8DACC);
  static const onPrimary           = Color(0xFFFFFFFF);
  static const onPrimaryContainer  = Color(0xFF00201A);
  static const secondary           = Color(0xFF4A7C59);
  static const secondaryContainer  = Color(0xFFC1E8C8);
  static const onSecondary         = Color(0xFFFFFFFF);
  static const onSecondaryContainer= Color(0xFF0B2112);
  static const tertiary            = Color(0xFF6B7B6E);
  static const tertiaryContainer   = Color(0xFFDDE8DE);
  static const onTertiary          = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF1A2B1D);
  static const surface             = Color(0xFFF6FAF8);
  static const surfaceVariant      = Color(0xFFEDF4F0);
  static const onSurface           = Color(0xFF1A1C1A);
  static const onSurfaceVariant    = Color(0xFF404944);
  static const background          = Color(0xFFF6FAF8);
  static const outline             = Color(0xFF8FA89A);
  static const outlineVariant      = Color(0xFFD8E5DC);
  static const error               = Color(0xFFB3261E);
  static const errorContainer      = Color(0xFFF9DEDC);
  static const inverseSurface      = Color(0xFF2A312D);
  static const inverseOnSurface    = Color(0xFFEDF4F0);
  static const success             = Color(0xFF16A34A);

  // Mood accents
  static const moodMelancholic = Color(0xFF6366F1);
  static const moodRomantic    = Color(0xFFEC4899);
  static const moodJoyful      = Color(0xFFF59E0B);
  static const moodAngry       = Color(0xFFEF4444);
  static const moodPeaceful    = Color(0xFF1F6B5A);
  static const moodNostalgic   = Color(0xFF8B5CF6);
  static const moodMysterious  = Color(0xFF1F2937);
  static const moodSpiritual   = Color(0xFFD97706);

  static Color mood(String m) => {
    'melancholic': moodMelancholic, 'romantic': moodRomantic,
    'joyful': moodJoyful, 'angry': moodAngry, 'peaceful': moodPeaceful,
    'nostalgic': moodNostalgic, 'mysterious': moodMysterious,
    'spiritual': moodSpiritual,
  }[m] ?? primary;
}
```

---

## 1.3 Typography System

### Typefaces

```
Playfair Display   GoogleFonts.playfairDisplay()
  Purpose: The literary soul. Poem titles, story titles, display text,
           English poem body. Evokes classic book typography.

DM Sans            GoogleFonts.dmSans()
  Purpose: Clean modern chrome. All UI labels, buttons, metadata,
           captions, counts. Readable at 11sp.

System Default     (no fontFamily set)
  Purpose: Bengali/Bangla text ONLY. Android resolves to Noto Serif Bengali.
  RULE: Never set fontFamily on any Bengali-language content. Not even
        to "system". Simply omit the fontFamily property entirely.
```

### Complete Type Scale

```
┌─────────────────┬────────────────┬──────┬────────┬─────┬──────────────────────────────────┐
│ Token           │ Font           │ Size │ Lh     │ Wt  │ Usage                            │
├─────────────────┼────────────────┼──────┼────────┼─────┼──────────────────────────────────┤
│ displayLarge    │ Playfair       │ 57sp │ 64sp   │ 700 │ Welcome hero title only          │
│ headlineLarge   │ Playfair       │ 32sp │ 40sp   │ 600 │ Poem reader title                │
│ headlineMedium  │ Playfair       │ 28sp │ 36sp   │ 600 │ Section headers, story titles    │
│ headlineSmall   │ Playfair       │ 24sp │ 32sp   │ 600 │ Screen titles, onboarding heads  │
│ titleLarge      │ DM Sans        │ 22sp │ 28sp   │ 500 │ Poem editor title input          │
│ titleMedium     │ DM Sans        │ 16sp │ 24sp   │ 500 │ Card story titles, nav labels    │
│ titleSmall      │ DM Sans        │ 14sp │ 20sp   │ 500 │ Author name on PoemCard/cards    │
│ bodyLarge       │ DM Sans        │ 16sp │ 24sp   │ 400 │ Poem preview text, UI body copy  │
│ bodyMedium      │ DM Sans        │ 14sp │ 20sp   │ 400 │ General content, descriptions    │
│ bodySmall       │ DM Sans        │ 12sp │ 16sp   │ 300 │ Card timestamps, helper text     │
│ labelLarge      │ DM Sans        │ 14sp │ 20sp   │ 500 │ Button labels, primary actions   │
│ labelMedium     │ DM Sans        │ 12sp │ 16sp   │ 400 │ Chip labels, tab labels, badges  │
│ labelSmall      │ DM Sans        │ 11sp │ 16sp   │ 400 │ Timestamps on cards, sub-labels  │
├─────────────────┼────────────────┼──────┼────────┼─────┼──────────────────────────────────┤
│ englishPoem     │ Playfair       │ 18sp │ 32sp   │ 400 │ EN poem body, +0.3 letterSpacing │
│ banglaPoem      │ System (none)  │ 18sp │ 38sp   │ 400 │ BN poem body — no fontFamily     │
└─────────────────┴────────────────┴──────┴────────┴─────┴──────────────────────────────────┘
```

```dart
// lib/core/theme/app_typography.dart
class AppTypography {
  static TextStyle get englishPoem => GoogleFonts.playfairDisplay(
    fontSize: 18, height: 32/18, letterSpacing: 0.3,
    color: AppColors.onSurface, fontWeight: FontWeight.w400,
  );

  // ⚠️ No fontFamily — system resolves to Noto Serif Bengali on Android
  static const TextStyle banglaPoem = TextStyle(
    fontSize: 18, height: 38/18, color: AppColors.onSurface,
    fontWeight: FontWeight.w400,
  );

  static TextStyle poemBody(String language) =>
    language == 'en' ? englishPoem : banglaPoem;

  static TextTheme get textTheme => TextTheme(
    displayLarge:   GoogleFonts.playfairDisplay(fontSize:57, fontWeight:FontWeight.w700, height:64/57),
    headlineLarge:  GoogleFonts.playfairDisplay(fontSize:32, fontWeight:FontWeight.w600, height:40/32),
    headlineMedium: GoogleFonts.playfairDisplay(fontSize:28, fontWeight:FontWeight.w600, height:36/28),
    headlineSmall:  GoogleFonts.playfairDisplay(fontSize:24, fontWeight:FontWeight.w600, height:32/24),
    titleLarge:     GoogleFonts.dmSans(fontSize:22, fontWeight:FontWeight.w500, height:28/22),
    titleMedium:    GoogleFonts.dmSans(fontSize:16, fontWeight:FontWeight.w500, height:24/16),
    titleSmall:     GoogleFonts.dmSans(fontSize:14, fontWeight:FontWeight.w500, height:20/14),
    bodyLarge:      GoogleFonts.dmSans(fontSize:16, fontWeight:FontWeight.w400, height:24/16),
    bodyMedium:     GoogleFonts.dmSans(fontSize:14, fontWeight:FontWeight.w400, height:20/14),
    bodySmall:      GoogleFonts.dmSans(fontSize:12, fontWeight:FontWeight.w300, height:16/12),
    labelLarge:     GoogleFonts.dmSans(fontSize:14, fontWeight:FontWeight.w500, height:20/14),
    labelMedium:    GoogleFonts.dmSans(fontSize:12, fontWeight:FontWeight.w400, height:16/12),
    labelSmall:     GoogleFonts.dmSans(fontSize:11, fontWeight:FontWeight.w400, height:16/11),
  );
}
```

---

## 1.4 Grid & Spacing System

### Base Unit: 4dp

All spacing values are multiples of 4dp. Never use arbitrary values.

```
┌────────────┬───────┬──────────────────────────────────────────────────┐
│ Token      │ Value │ Use                                              │
├────────────┼───────┼──────────────────────────────────────────────────┤
│ space1     │  4dp  │ Icon internal padding, micro gaps                │
│ space2     │  8dp  │ Chip padding, icon-to-label gaps                 │
│ space3     │ 12dp  │ Card internal padding (tight)                    │
│ space4     │ 16dp  │ Standard margin, card full padding               │
│ space6     │ 24dp  │ Between content sections                         │
│ space8     │ 32dp  │ Hero spacing, large gaps, cover margin           │
│ space12    │ 48dp  │ Screen-safe top/bottom, empty state padding      │
└────────────┴───────┴──────────────────────────────────────────────────┘
```

### Screen Grid

```
Viewport: 360dp standard Android screen (scales to all sizes)

┌─────────────────────────────────────────┐
│ 16dp │     Content Zone (328dp)  │ 16dp │
│      │                           │      │
│      │ Full-width card: 328dp    │      │
│      │                           │      │
│      │ 2-col grid:               │      │
│      │  (328 - 8dp gap) / 2      │      │
│      │  = 160dp per column       │      │
│      │                           │      │
│      │ 3-col chips:              │      │
│      │  (328 - 16dp gaps) / 3    │      │
│      │  = 104dp per chip         │      │
│      │                           │      │
│      │ Horizontal scroll cards:  │      │
│      │  80% width = 262dp        │      │
│      │  First card peek 16dp     │      │
└─────────────────────────────────────────┘

Safe zones:
  Status bar:   handled by SafeArea
  AppBar:       56–64dp (specified per screen)
  Bottom nav:   80dp fixed
  Keyboard:     resizeToAvoidBottomInset: true
```

---

## 1.5 Shape System

```dart
// lib/core/theme/app_shapes.dart
class AppShapes {
  static const xs   = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)));
  static const sm   = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)));
  static const md   = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
  static const lg   = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)));
  static const xl   = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28)));
  static const full = CircleBorder();
  static const sheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );
}
```

```
Token  Value  Applied to
─────────────────────────────────────────────────────────
xs      4dp   Chips, tags, snackbars, filter chips
sm      8dp   Text inputs, search bar, OTP boxes, buttons
md     12dp   Cards (PoemCard, ThoughtCard, StoryCard)
lg     16dp   Bottom sheets, modals, sign-in card
xl     28dp   FAB write button
full   50%    Avatars, circular icon buttons, live pill
sheet        lg top corners only — bottom sheets
```

---

## 1.6 Elevation — Tonal Only (No Drop Shadows)

M3 uses colour tint to convey elevation. No `boxShadow` except video feed overlays.

```
Level 0 — 0%   Background, scaffold body
Level 1 — 5%   PoemCard, ThoughtCard, StoryCard
Level 2 — 8%   Elevated buttons, editor toolbar
Level 3 — 11%  Sign-in card, FAB
Level 4 — 12%  NavigationBar
Level 5 — 14%  Dialogs, modals
```

Set via `elevation:` on `Card`, `Material`, or `ElevatedButton`. Flutter M3 applies the tint automatically using the `primary` color.

---

## 1.7 Background Designs

Backgrounds are never plain flat fills. Each context has a subtle living quality.

### BG-01 — Default Screen Background (Feed, Profile, Discover)

```
Base: Background (#F6FAF8)
Texture: None — pure vellum whiteness is the texture
Extra: None — content IS the decoration

Flutter prompt:
  Scaffold(backgroundColor: AppColors.background, ...)
  // That's it. The sage cards create the visual rhythm against the white page.
```

### BG-02 — Welcome & Onboarding Background

```
Base: Background (#F6FAF8)
Overlay: Radial gradient centred top-right corner
  Gradient: [Primary.withValues(alpha: 0.06) at centre, transparent at edge]
  Radius: 60% of screen width
  Position: topRight alignment

Floating leaf shapes (optional decorative layer):
  3 very faint sage circles — no border, filled with Primary.withValues(alpha: 0.03)
  Sizes: 180dp, 120dp, 80dp
  Positions: top-right offset (-40dp, -40dp), bottom-left (-60dp, 80dp), centre-right (screen-right - 20, screen/2)
  They don't move — they are permanent, barely visible watermark shapes

Flutter prompt:
  Stack(children: [
    Container(
      decoration: const BoxDecoration(color: AppColors.background),
    ),
    // Top-right radial glow
    Positioned(
      top: -80, right: -80,
      child: Container(
        width: 280, height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.primary.withValues(alpha: 0.07), Colors.transparent],
          ),
        ),
      ),
    ),
    // Bottom-left soft circle
    Positioned(
      bottom: 60, left: -60,
      child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryContainer.withValues(alpha: 0.25),
        ),
      ),
    ),
    // Page content
    child,
  ])
```

### BG-03 — Poem Reader Background

```
Base: Background (#F6FAF8)
Character: Maximum breathing space — no decorative elements at all
The poem body IS the background experience

Flutter prompt:
  Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: AppColors.background,
    // No additional decoration
  )
```

### BG-04 — Video Feed Background

```
Base: Colors.black (pure #000000)
Overlay layers (applied to each video item):
  Top gradient: LinearGradient top→bottom
    [Colors.black.withValues(alpha: 0.5), Colors.transparent]
    height: 160dp (covers status bar through top controls)
  Bottom gradient: LinearGradient bottom→top
    [Colors.black.withValues(alpha: 0.75), Colors.transparent]
    height: 260dp (covers poem info + actions)

Flutter prompt:
  Scaffold(backgroundColor: Colors.black)
  // Per video item:
  Positioned(
    top: 0, left: 0, right: 0, height: 160,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x80000000), Colors.transparent],
        ),
      ),
    ),
  ),
  Positioned(
    bottom: 0, left: 0, right: 0, height: 260,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Color(0xBF000000), Colors.transparent],
        ),
      ),
    ),
  ),
```

### BG-05 — Bottom Sheet Background

```
Base: Surface (#F6FAF8)
Handle: 32×4dp pill centred, Outline Variant colour, 12dp from top
Backdrop: Colors.black.withValues(alpha: 0.32) scrim behind sheet

Flutter prompt:
  showModalBottomSheet(
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    shape: AppShapes.sheet,
    ...
  )
```

### BG-06 — Auth Card Background (Sign In / Sign Up)

```
Outer: BG-02 (welcome background with sage glows)
Card:
  Background: Surface (#F6FAF8)
  Elevation: Level 3 (11% tint)
  Corner: 16dp
  Shadow: none — tonal elevation only
  Margin: 24dp horizontal, auto vertical centered
  Padding: 24dp all sides

Flutter prompt:
  Card(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    elevation: 3,
    color: AppColors.surface,
    shape: AppShapes.lg,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: column_of_inputs,
    ),
  )
```

---

# PART 2 — ANIMATION SYSTEM

---

## 2.1 Animation Constants

```dart
// lib/core/theme/app_animations.dart
class AppDurations {
  static const instant    = Duration(milliseconds: 100);
  static const quick      = Duration(milliseconds: 150);
  static const standard   = Duration(milliseconds: 250);
  static const emphasized = Duration(milliseconds: 350);
  static const expressive = Duration(milliseconds: 500);
  static const prose      = Duration(milliseconds: 800);
  static const shimmer    = Duration(milliseconds: 1500);
  static const pulse      = Duration(milliseconds: 1200);
}

class AppCurves {
  static const emphasized  = Curves.easeInOutCubicEmphasized;
  static const sheetOpen   = Cubic(0.05, 0.7, 0.1, 1.0);
  static const sheetClose  = Cubic(0.3, 0.0, 0.8, 0.15);
  static const standard    = Curves.easeInOut;
  static const decelerate  = Curves.easeOut;
  static const accelerate  = Curves.easeIn;
  static const spring      = Curves.elasticOut;
}

// Reduced motion check — wrap every animation with this
bool reducedMotion(BuildContext ctx) =>
  MediaQuery.of(ctx).disableAnimations;
```

## 2.2 Reduced Motion Rule

**Every single animation below must have a reduced motion fallback — no exceptions.**

This is an accessibility requirement. Users who enable "Remove animations" in Android
accessibility settings must still get a fully functional, readable app.

```dart
// ── RULE ─────────────────────────────────────────────────────────────────
// Before implementing ANY animation, wrap it in a reduced-motion check:

final bool noMotion = MediaQuery.of(context).disableAnimations;

// If noMotion is true:
//   → Replace the full animation with a simple 150ms fadeIn only
//   → No scale, no slide, no rotation, no spring — opacity ONLY
// If noMotion is false:
//   → Use the full animation as specified in the A01–A30 catalogue

// ── PATTERN ──────────────────────────────────────────────────────────────
// For flutter_animate chains:
noMotion
  ? widget.animate().fadeIn(duration: AppDurations.quick)   // reduced
  : widget.animate()                                         // full
      .fadeIn(duration: AppDurations.emphasized)
      .slideY(begin: 0.08, end: 0, duration: AppDurations.emphasized);

// For AnimationController-based animations:
if (noMotion) {
  // Skip controller entirely — just show the final state immediately
  return finalStateWidget;
}
```

---

## 2.3 Animation Catalogue — All 30 Animations

**How to use this catalogue:**
- Animations are referenced by ID (e.g. `A06`) in screen specs and component specs
- Look up the ID here for the full Flutter implementation
- Every animation has: Element, Visual description, Timing, Flutter prompt
- Apply the reduced motion rule from Section 2.2 to every single animation below

**Quick index:**
```
A01 Sage Cursor Pulse          A11 Duel Vote Ripple
A02 Heart Like Burst           A12 Live Poll Fill
A03 Skeleton Shimmer           A13 Notification Bounce
A04 Bottom Sheet Entrance      A14 Mood Chip Select
A05 Page-to-Screen Expand      A15 Card Press Scale
A06 Card-to-Screen Transition  A16 FAB Write Button Tap
A07 Pull-to-Refresh Quill      A17 OTP Input Error Shake
A08 Publish Fireworks          A18 Profile Tab Indicator
A09 Video Feed Snap            A19 Staggered List Entrance
A10 Story Progress Fill        A20 Welcome Screen Entrance
                               A21 Story Part Navigation
                               A22 Thought Visibility Picker
                               A23 Collab Stanza Branch Fork
                               A24 Chat Message Send
                               A25 Poem Reaction Picker
                               A26 Follow Button Morph
                               A27 Search Results Entrance
                               A28 Audio Waveform Player
                               A29 Save/Bookmark Toggle
                               A30 Username Availability Pulse
```

---

### A01 — Sage Cursor Pulse
```
Element: Poem editor text cursor
Visual:  Cursor opacity 1.0 → 0.3 → 1.0, infinite loop
         Like a candle flame — alive, inviting
Timing:  800ms, easeInOut, repeat(reverse: true)
Trigger: Always active while editor is focused

Flutter prompt:
  late AnimationController _cursorAnim;

  @override
  void initState() {
    _cursorAnim = AnimationController(vsync: this, duration: AppDurations.prose)
      ..repeat(reverse: true);
  }

  // Wrap the custom cursor widget:
  FadeTransition(
    opacity: CurvedAnimation(parent: _cursorAnim, curve: AppCurves.standard),
    child: Container(
      width: 2, height: 22,
      color: AppColors.primary,
    ),
  )

  // In the TextField, set cursorColor and cursorWidth:
  TextField(
    cursorColor: AppColors.primary,
    cursorWidth: 2.0,
    // The Flutter cursor blinks by default — override with custom animated cursor
    // using a TextPainter overlay if full control is needed
  )
```

---

### A02 — Like Heart Spring Burst
```
Element: Like button (heart icon) on all cards and poem reader
Visual:  On tap: icon scale 1.0 → 1.5 → 1.0 with elastic spring
         Simultaneous: colour crossfade Outline → Primary (if liking)
                       colour crossfade Primary → Outline (if unliking)
         Particle burst: 6 tiny dots (3dp circles) fly outward 20dp and fade
         All fires IMMEDIATELY — optimistic, before API response
Timing:  Scale: 300ms elasticOut | Colour: 200ms easeOut | Particles: 400ms

Flutter prompt (flutter_animate):
  // Like button state widget:
  IconButton(
    onPressed: _onLikeTap,
    icon: Icon(
      _isLiked ? Icons.favorite : Icons.favorite_border,
      color: _isLiked ? AppColors.primary : AppColors.onSurfaceVariant,
    ).animate(controller: _heartController)
     .scale(
       begin: const Offset(1,1), end: const Offset(1.5,1.5),
       duration: 150.ms, curve: AppCurves.decelerate,
     )
     .then()
     .scale(
       begin: const Offset(1.5,1.5), end: const Offset(1,1),
       duration: 150.ms, curve: AppCurves.spring,
     ),
  )

  // Trigger:
  void _onLikeTap() {
    setState(() => _isLiked = !_isLiked);
    _heartController.forward(from: 0);
    // API call (optimistic — don't await)
    // likeProvider generated by @riverpod class Like extends _$Like
    ref.read(likeProvider.notifier).toggle(poemId);
  }
```

---

### A03 — Skeleton Shimmer
```
Element: All loading placeholders (PoemCard, ThoughtCard, StoryCard, Profile)
Visual:  Outline Variant (#D8E5DC) rects with a left→right white gradient sweep
         Like soft sunlight passing across vellum paper
Timing:  1500ms loop, infinite, linear
Shape:   Rounded rects matching the content they replace

Flutter prompt (flutter_animate):
  // Reusable shimmer rect:
  class ShimmerRect extends StatelessWidget {
    final double width, height;
    final double radius;
    const ShimmerRect({required this.width, required this.height, this.radius=4});

    @override Widget build(BuildContext context) {
      return Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: AppColors.outlineVariant,
          borderRadius: BorderRadius.circular(radius),
        ),
      ).animate(onPlay: (c) => c.repeat())
       .shimmer(
         duration: AppDurations.shimmer,
         color: Colors.white.withValues(alpha: 0.65),
         angle: 0.0,
         stops: const [0.0, 0.5, 1.0],
       );
    }
  }

  // PoemCard skeleton layout:
  Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Row(children: [
        ShimmerRect(width:40, height:40, radius:20),  // avatar
        const SizedBox(width:12),
        Column(children: [
          ShimmerRect(width:120, height:14),
          const SizedBox(height:4),
          ShimmerRect(width:80, height:12),
        ]),
      ]),
      const SizedBox(height:12),
      ShimmerRect(width:double.infinity, height:20),  // title
      const SizedBox(height:8),
      ShimmerRect(width:double.infinity, height:14),  // line 1
      const SizedBox(height:4),
      ShimmerRect(width:240, height:14),              // line 2
      const SizedBox(height:4),
      ShimmerRect(width:200, height:14),              // line 3
      const SizedBox(height:12),
      Row(children: [
        ShimmerRect(width:48, height:12),
        const SizedBox(width:16),
        ShimmerRect(width:48, height:12),
        const SizedBox(width:16),
        ShimmerRect(width:48, height:12),
      ]),
    ]),
  )
```

---

### A04 — Bottom Sheet Enter / Exit
```
Element: CommentSheet, ThoughtComposerSheet, ContentTypePicker, MoodFilterSheet
Visual:  Open: slides up from bottom, decelerates smoothly into position
                backdrop scrim fades in simultaneously
         Close: accelerates upward and out, scrim fades out
         Drag handle at top — drag down to dismiss
Timing:  Open 350ms sheetOpen curve | Close 250ms sheetClose curve

Flutter prompt:
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    shape: AppShapes.sheet,
    enableDrag: true,
    transitionAnimationController: AnimationController(
      vsync: this,
      duration: AppDurations.emphasized,
      reverseDuration: AppDurations.standard,
    )..addListener(() => setState((){})),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: initialSize,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (_, controller) => content,
    ),
  )

  // Handle widget (place at top of every sheet):
  Center(
    child: Container(
      width: 32, height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  )
```

---

### A05 — Feed Filter Chip Activation
```
Element: Horizontal filter bar chips (All / Following / Poems / Stories / etc.)
Visual:  Tap: background fills from surfaceVariant to secondaryContainer
              text colour shifts from Outline to Primary
              pill scale 1.0 → 1.04 → 1.0
              previously active chip reverse-animates simultaneously
Timing:  150ms easeInOut fill | 100ms scale

Flutter prompt:
  GestureDetector(
    onTap: () => onSelect(label),
    child: AnimatedContainer(
      duration: AppDurations.quick,
      curve: AppCurves.standard,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: isActive ? null : Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Text(label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isActive ? AppColors.primary : AppColors.outline,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    ),
  ).animate(target: isActive ? 1.0 : 0.0)
   .scale(
     begin: const Offset(1,1), end: const Offset(1.04,1.04),
     duration: 100.ms, curve: AppCurves.decelerate,
   )
   .then()
   .scale(end: const Offset(1,1), duration: 100.ms)
```

---

### A06 — Screen / Page Transition
```
Element: Navigation between screens via go_router
Visual:  Entering screen: fades in + slides up 6% of screen height
         Exiting screen: fades out, stays in place (no reverse slide)
         Feel: turning a page in a book — gentle, literary
Timing:  350ms emphasised curve

Flutter prompt:
  // Apply to all GoRoute definitions:
  GoRoute(
    path: '/poem/:id',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: PoemReaderScreen(id: state.pathParameters['id']!),
      transitionDuration: AppDurations.emphasized,
      reverseTransitionDuration: AppDurations.standard,
      transitionsBuilder: (context, animation, secondary, child) {
        final fade = CurvedAnimation(parent: animation, curve: AppCurves.emphasized);
        final slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: AppCurves.sheetOpen));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    ),
  )
```

---

### A07 — Follow Button State Morph
```
Element: Follow/Unfollow button on other user profiles
Visual:  Not Following → Following:
           bg colour fills from transparent to Primary (#1F6B5A)
           border fades from outline to none
           text crossfades "Follow" → "Following" via AnimatedSwitcher
           icon: person_add → person (crossfade)
         Following → Not Following (on confirm tap):
           reverse of above + brief shake animation
Timing:  250ms easeInOut fill | 150ms text crossfade

Flutter prompt:
  AnimatedContainer(
    duration: AppDurations.standard,
    curve: AppCurves.standard,
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: isFollowing ? AppColors.surfaceVariant : AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      border: isFollowing ? Border.all(color: AppColors.outline) : null,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedSwitcher(
        duration: AppDurations.quick,
        child: Icon(
          isFollowing ? Icons.person : Icons.person_add_outlined,
          key: ValueKey(isFollowing),
          size: 18,
          color: isFollowing ? AppColors.onSurface : AppColors.onPrimary,
        ),
      ),
      const SizedBox(width: 6),
      AnimatedSwitcher(
        duration: AppDurations.quick,
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          key: ValueKey(isFollowing),
          style: TextStyle(
            color: isFollowing ? AppColors.onSurface : AppColors.onPrimary,
            fontSize: 14, fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ]),
  )
```

---

### A08 — Video Feed Page Snap
```
Element: Full-screen vertical video feed
Visual:  Swipe up/down — hard snap to next/previous video
         Active video plays, others are paused
         Bottom info layer has subtle parallax (+/- 12dp) during swipe transition
         Play/pause: tap centre → 48dp semi-transparent circle flashes
Timing:  Physics-based spring snap | Parallax ties to swipe progress

Flutter prompt:
  PageView.builder(
    scrollDirection: Axis.vertical,
    controller: _pageController,
    physics: const PageScrollPhysics().applyTo(const ClampingScrollPhysics()),
    onPageChanged: (i) {
      _controllers[i]?.play();
      if (i > 0) _controllers[i-1]?.pause();
      if (i < _poems.length-1) _controllers[i+1]?.pause();
      setState(() => _currentPage = i);
    },
    itemBuilder: (_, i) {
      // Parallax for bottom info:
      return AnimatedBuilder(
        animation: _pageController,
        builder: (_, child) {
          double offset = 0;
          if (_pageController.hasClients && _pageController.page != null) {
            offset = (_pageController.page! - i) * 12;
          }
          return Stack(children: [
            VideoPlayerWidget(controller: _controllers[i]!, isActive: i == _currentPage),
            _gradients(),
            Positioned(
              bottom: 88 + offset,  // parallax shift
              left: 16, right: 80,
              child: _BottomInfo(poem: _poems[i]),
            ),
          ]);
        },
      );
    },
  )
```

---

### A09 — Poem Publish Celebration
```
Element: Publish button after successful API response
Visual:  1. Publish button emits a soft sage glow (radial, 32dp radius, 40% opacity)
         2. Glow pulses once (500ms)
         3. Snackbar slides up: "Your words are now part of the world."
         4. Screen navigates away after 800ms
Timing:  Glow: 500ms out+in | Snackbar enter: 350ms | Total ritual: ~1.5s

Flutter prompt:
  void _onPublishSuccess() {
    setState(() => _isPublishing = false);
    // Glow animation
    _glowController.forward().then((_) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        _poeticSnackbar('Your words are now part of the world.'),
      );
      // Navigate after brief pause
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) context.pop();
      });
    });
  }

  // In build:
  AnimatedBuilder(
    animation: _glowController,
    builder: (_, child) => Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.35 * _glowController.value),
          blurRadius: 32 * _glowController.value,
          spreadRadius: 4 * _glowController.value,
        )],
      ),
      child: child,
    ),
    child: FilledButton(onPressed: _publish, child: const Text('Publish')),
  )
```

---

### A10 — Mood Card Selection (Onboarding)
```
Element: 2×4 mood grid on onboarding moods screen
Visual:  Unselected → Selected:
           Scale 1.0 → 1.04 (spring)
           2dp Primary border appears (fade in 150ms)
           ✓ badge fades in top-right (100ms)
         4th selection: first-selected card reverse-animates (de-selects)
         Deselected → Unselected: reverse of above
Timing:  Scale 150ms spring | Border 150ms | Badge 100ms

Flutter prompt:
  AnimatedContainer(
    duration: AppDurations.quick,
    transform: Matrix4.identity()..scale(isSelected ? 1.04 : 1.0),
    transformAlignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.mood(mood.key).withValues(alpha: 0.65),
          AppColors.mood(mood.key).withValues(alpha: 0.35),
        ],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: isSelected
        ? Border.all(color: AppColors.primary, width: 2)
        : Border.all(color: Colors.transparent, width: 2),
    ),
    child: Stack(children: [
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(mood.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
      ])),
      if (isSelected)
        Positioned(
          top: 8, right: 8,
          child: Container(
            width: 20, height: 20,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 13, color: Colors.white),
          ).animate().fadeIn(duration: 100.ms).scale(begin: const Offset(0.6,0.6)),
        ),
    ]),
  )
```

---

### A11 — Duel Vote Progress Bars
```
Element: Duel feed card and duel detail screen
Visual:  After vote: both bars animate from old value to new value
         Primary-coloured bar = challenger side
         Secondary-coloured bar = challengee side
         Both animate simultaneously, 50ms stagger
         Percentage labels count up (interpolated number)
Timing:  600ms elasticOut

Flutter prompt:
  // For each bar:
  TweenAnimationBuilder<double>(
    key: ValueKey(_lastVoteTime),  // re-trigger on new vote
    tween: Tween(begin: _previousPercent, end: _currentPercent),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${(value * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isChallenger ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const Spacer(),
          Text(poetName, style: Theme.of(context).textTheme.labelSmall),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.tertiaryContainer,
            valueColor: AlwaysStoppedAnimation(
              isChallenger ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ),
      ]);
    },
  )
```

---

### A12 — Collab Live Stanza Appear
```
Element: Collaborative poem screen — new stanza arrives via Pusher
Visual:  New stanza slides in from right edge + fades in
         "Live" pill: green dot pulses (opacity 1→0→1, 1200ms loop)
         Stanza left-border colour uses author's assigned colour
Timing:  Slide + fade: 300ms easeOut | Pulse: 1200ms loop

Flutter prompt:
  // New stanza appearing:
  StanzaBlock(stanza: newStanza)
    .animate()
    .fadeIn(duration: 300.ms, curve: AppCurves.decelerate)
    .slideX(begin: 0.25, end: 0, duration: 300.ms, curve: AppCurves.sheetOpen)

  // Live indicator pill:
  Row(children: [
    Container(
      width: 7, height: 7,
      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .fadeOut(duration: const Duration(milliseconds: 600)),
    const SizedBox(width: 5),
    const Text('Live', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w500)),
  ])
```

---

### A13 — Notification Bell Bounce
```
Element: Bell icon in feed AppBar, triggered on new notification
Visual:  Bell rotates ±12° × 3 oscillations (like a real bell ringing)
         Badge count increments with a scale pulse 1.0→1.4→1.0
Timing:  Total 600ms | Scale: 200ms

Flutter prompt:
  AnimationController _bell = AnimationController(vsync: this, duration: 600.ms);
  Animation<double> _bellRotation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.033),  weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.033, end:-0.033), weight: 2),
    TweenSequenceItem(tween: Tween(begin:-0.033, end: 0.033), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 0.033, end:-0.033), weight: 2),
    TweenSequenceItem(tween: Tween(begin:-0.033, end: 0.0),   weight: 1),
  ]).animate(_bell);

  Stack(children: [
    RotationTransition(turns: _bellRotation, child: const Icon(Icons.notifications_outlined)),
    if (_unreadCount > 0)
      Positioned(top:0, right:0,
        child: Container(
          width: 16, height: 16, alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Text('$_unreadCount', style: const TextStyle(fontSize: 10, color: Colors.white)),
        ).animate(key: ValueKey(_unreadCount))
         .scale(begin: const Offset(0.6,0.6), duration: 200.ms, curve: AppCurves.spring),
      ),
  ])
  // Trigger: _bell.forward(from: 0) when new notification arrives via websocket/FCM
```

---

### A14 — App Bar Scroll Hide / Show
```
Element: Top app bar on Feed, Discover, Profile
Visual:  Scroll down → app bar slides up and fades out
         Scroll up even slightly → app bar slides back down and fades in
         Filter bar sticks just below the app bar position
Timing:  Flutter SliverAppBar built-in (floating:true, snap:true)

Flutter prompt:
  CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverAppBar(
        floating: true,
        snap: true,
        pinned: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        toolbarHeight: 56,
        title: /* app bar content */,
      ),
      SliverPersistentHeader(
        pinned: true,
        delegate: _FilterBarDelegate(),  // filter bar sticks
      ),
      SliverPadding(
        padding: const EdgeInsets.only(top: 8),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(/* feed items */)),
      ),
    ],
  )
```

---

### A15 — Card Press Ripple
```
Element: All tappable cards (PoemCard, ThoughtCard, StoryCard, etc.)
Visual:  InkWell ripple in primaryContainer colour, contained within card border radius
         Card scales very slightly: 1.0 → 0.98 on press down, spring back on release
Timing:  Scale press: 100ms | Scale release: 200ms spring

Flutter prompt:
  Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primaryContainer.withValues(alpha: 0.4),
      highlightColor: AppColors.primaryContainer.withValues(alpha: 0.15),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: _pressed ? AppDurations.instant : AppDurations.quick,
        curve: _pressed ? AppCurves.accelerate : AppCurves.spring,
        child: /* card content */,
      ),
    ),
  )
```

---

### A16 — FAB Write Button Tap
```
Element: Centre Write FAB in bottom navigation
Visual:  Tap: scale 1.0 → 0.88 (compress) → 1.0 (spring back)
              Primary bg briefly brightens to #2A7A67
         Long press: scale 1.05, shows tooltip "Create"
Timing:  Compress: 100ms | Spring: 200ms elasticOut

Flutter prompt:
  GestureDetector(
    onTapDown: (_) => _fabController.forward(),
    onTapUp: (_) { _fabController.reverse(); _openPicker(); },
    onTapCancel: () => _fabController.reverse(),
    child: ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _fabController, curve: AppCurves.accelerate)),
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: null,  // handled by GestureDetector
        child: const Icon(Icons.edit_outlined, color: AppColors.onPrimary, size: 26),
      ),
    ),
  )
```

---

### A17 — OTP Input Box Focus + Error Shake
```
Element: 6-box OTP input on verify-otp and password reset screens
Visual:  Focus: active box border becomes 2dp Primary + scale 1.0→1.04
         Fill: filled box bg tints to surfaceVariant
         Error: ALL 6 boxes shake horizontally + borders turn Error red
         Auto-advance: cursor jumps to next box as each digit is entered
Timing:  Focus scale: 100ms | Shake: 400ms, 4 oscillations

Flutter prompt:
  // Error shake on wrong OTP:
  Row(children: List.generate(6, (i) => _OtpBox(
    controller: _controllers[i],
    focusNode: _focusNodes[i],
    hasError: _hasError,
    isFocused: _focusedIndex == i,
    value: _values[i],
  ))).animate(target: _hasError ? 1.0 : 0.0)
   .shakeX(
     amount: 7,
     hz: 4,
     duration: const Duration(milliseconds: 400),
     curve: Curves.linear,
   )

  // Individual box:
  AnimatedContainer(
    duration: AppDurations.quick,
    width: 48, height: 58,
    transform: Matrix4.identity()..scale(isFocused ? 1.04 : 1.0),
    transformAlignment: Alignment.center,
    decoration: BoxDecoration(
      color: value.isNotEmpty ? AppColors.surfaceVariant : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: _hasError ? AppColors.error
             : isFocused ? AppColors.primary
             : value.isNotEmpty ? AppColors.outline
             : AppColors.outlineVariant,
        width: isFocused || _hasError ? 2 : 1.5,
      ),
    ),
    child: TextField(/* single digit, number-pad */),
  )
```

---

### A18 — Profile Tab Indicator Slide
```
Element: Profile screen content tabs (Poems | Stories | Thoughts | Liked)
Visual:  Active tab: animated pill indicator slides from old tab to new
         Underline morphs position with spring — not a hard jump
         Active text: primary colour, medium weight
         Inactive: onSurfaceVariant, regular weight
Timing:  250ms easeInOut slide

Flutter prompt:
  TabBar(
    controller: _tabController,
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14),
    unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w400, fontSize: 14),
    tabs: const [
      Tab(text: 'Poems'),
      Tab(text: 'Stories'),
      Tab(text: 'Thoughts'),
      Tab(text: 'Liked'),
    ],
  )
```

---

### A19 — Staggered List Entrance
```
Element: Feed items on initial load, search results, notification list items
Visual:  Each card fades in + slides up 12dp
         Staggered: 60ms delay between each item (max 8 items animated, rest instant)
Timing:  Each: 350ms | Stagger: 60ms per item

Flutter prompt:
  ListView.builder(
    itemBuilder: (context, index) {
      final delay = Duration(milliseconds: (index < 8 ? index * 60 : 0));
      return FeedItem(data: items[index])
        .animate(delay: delay)
        .fadeIn(duration: AppDurations.emphasized, curve: AppCurves.decelerate)
        .slideY(
          begin: 0.08, end: 0,
          duration: AppDurations.emphasized,
          curve: AppCurves.sheetOpen,
        );
    },
  )
```

---

### A20 — Welcome Screen Entrance (Staggered Hero)
```
Element: Welcome screen on first app open
Visual:  Elements appear sequentially from centre outward:
         Icon: scale 0.7→1.0 + fadeIn, 500ms, delay 0
         Title: slideY 0.15→0 + fadeIn, 400ms, delay 150ms
         Subtitle: fadeIn only, 300ms, delay 350ms
         CTA button: slideY 0.2→0 + fadeIn, 400ms, delay 550ms
         Sign in link: fadeIn only, 300ms, delay 750ms
Timing:  Total entrance: ~1050ms

Flutter prompt:
  // Apply to each element:
  quillIcon
    .animate()
    .scale(begin: const Offset(0.7,0.7), duration: AppDurations.expressive, curve: AppCurves.spring)
    .fadeIn(duration: AppDurations.expressive)

  titleText
    .animate(delay: 150.ms)
    .slideY(begin: 0.15, end: 0, duration: AppDurations.emphasized, curve: AppCurves.sheetOpen)
    .fadeIn(duration: AppDurations.emphasized)

  subtitleText.animate(delay: 350.ms).fadeIn(duration: AppDurations.standard)

  ctaButton
    .animate(delay: 550.ms)
    .slideY(begin: 0.2, end: 0, duration: AppDurations.emphasized, curve: AppCurves.sheetOpen)
    .fadeIn(duration: AppDurations.emphasized)

  signInLink.animate(delay: 750.ms).fadeIn(duration: AppDurations.standard)
```

---

### A21 — Story Part Reader Prev/Next Navigation
```
Element: Previous/Next part navigation buttons in story part reader
Visual:  "← Previous Part" / "Next Part →" at bottom
         Tap next: current content slides left + fades, new slides in from right
         Tap prev: current slides right + fades, new slides in from left
         Bottom bar pulses momentarily after navigation
Timing:  Exit: 200ms | Enter: 350ms | Stagger: exit starts, enter starts at 150ms

Flutter prompt:
  AnimatedSwitcher(
    duration: AppDurations.emphasized,
    transitionBuilder: (child, animation) {
      final isForward = _direction == NavigationDirection.forward;
      final offset = isForward
        ? Tween<Offset>(begin: const Offset(1,0), end: Offset.zero)
        : Tween<Offset>(begin: const Offset(-1,0), end: Offset.zero);
      return SlideTransition(
        position: offset.animate(CurvedAnimation(parent: animation, curve: AppCurves.sheetOpen)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    child: StoryPartContent(key: ValueKey(_currentPartId), part: _currentPart),
  )
```

---

### A22 — Thought Visibility Picker Slide
```
Element: [Public | Mutual | Private] segmented visibility picker in ThoughtComposer
Visual:  Active segment: primary bg pill slides (not jumps) under the labels
         Icon morphs: globe → group → lock
         Text colour: active=white, inactive=onSurfaceVariant
Timing:  200ms easeInOut slide

Flutter prompt:
  Stack(children: [
    // Sliding pill background:
    AnimatedPositioned(
      duration: AppDurations.standard,
      curve: AppCurves.standard,
      left: _selectedIndex * (pillWidth + 4.0) + 4,
      top: 4, bottom: 4,
      width: pillWidth,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Labels row:
    Row(children: _options.asMap().entries.map((e) =>
      GestureDetector(
        onTap: () => setState(() => _selectedIndex = e.key),
        child: SizedBox(
          width: pillWidth + 8,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(e.value.icon, size: 16,
              color: _selectedIndex == e.key ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(e.value.label,
              style: TextStyle(
                color: _selectedIndex == e.key ? Colors.white : AppColors.onSurfaceVariant,
                fontSize: 12, fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      )
    ).toList()),
  ])
```

---

### A23 — Collab Poem Stanza Branch Fork
```
Element: Branching mode collab poem — choosing between branch paths
Visual:  Two branch options fan out from current stanza with a curved connector line
         Selecting a branch: chosen side scales up 1.0→1.03, other dims opacity 1.0→0.5
         Connector line animates from dashed to solid in Primary colour
Timing:  Scale + opacity: 200ms | Line: 300ms draw

Flutter prompt:
  AnimatedContainer(
    duration: AppDurations.standard,
    transform: Matrix4.identity()..scale(isSelected ? 1.03 : 1.0),
    child: Opacity(
      opacity: otherIsSelected ? 0.5 : 1.0,
      child: StanzaBranchCard(stanza: branch),
    ),
  )
```

---

### A24 — Chat Message Send
```
Element: Message thread — sending a new message
Visual:  Message bubble appears from input field position — small bubble
         grows to full size at the end of the list (scale 0.6→1.0 + fade)
         Send button: spins 360° as message sends, then snaps to original
Timing:  Bubble appear: 200ms spring | Send spin: 300ms

Flutter prompt:
  // New own message:
  Align(
    alignment: Alignment.centerRight,
    child: MessageBubble(message: newMessage)
      .animate()
      .scale(begin: const Offset(0.6,0.6), duration: 200.ms, curve: AppCurves.spring)
      .fadeIn(duration: 150.ms),
  )

  // Send button spin:
  IconButton(
    icon: Icon(Icons.send).animate(controller: _sendController)
      .rotate(begin: 0, end: 1, duration: 300.ms, curve: AppCurves.standard),
    onPressed: _sendMessage,
  )
```

---

### A25 — Duel Invitation Accept/Decline
```
Element: Pending duel notification → duel screen
Visual:  Accept button: fills green (success) → brief full-screen flash of Primary at 8% opacity
         Decline button: fades to error red, card slides up and away
         Both have haptic feedback (HapticFeedback.mediumImpact)
Timing:  Accept fill: 300ms | Full-screen flash: 200ms out + 200ms in | Decline exit: 300ms

Flutter prompt:
  // Accept flash overlay:
  void _acceptDuel() {
    HapticFeedback.mediumImpact();
    _flashController.forward().then((_) => _flashController.reverse());
    // duelProvider generated by @riverpod class Duel extends _$Duel (family param: duelId)
    ref.read(duelProvider.notifier).accept(_duelId);
  }

  // Overlay widget:
  AnimatedBuilder(
    animation: _flashController,
    builder: (_, __) => IgnorePointer(
      child: Container(
        color: AppColors.primary.withValues(alpha: 0.08 * _flashController.value),
      ),
    ),
  )
```

---

### A26 — Discover Horizontal Scroll Snap
```
Element: Trending poems horizontal scroll on Discover screen
Visual:  Horizontal scroll with momentum and snap-to-card behaviour
         Cards at the edges partially visible (peek: 16dp from edge)
         Active card: full opacity, others: 0.85 opacity (depth effect)
Timing:  Physics-based momentum snap

Flutter prompt:
  ListView.builder(
    scrollDirection: Axis.horizontal,
    controller: _scrollController,
    clipBehavior: Clip.none,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemBuilder: (context, index) {
      return AnimatedBuilder(
        animation: _scrollController,
        builder: (_, child) {
          double opacity = 1.0;
          if (_scrollController.hasClients) {
            final itemPos = index * (cardWidth + 8.0);
            final scrollPos = _scrollController.offset;
            final diff = (itemPos - scrollPos).abs();
            opacity = (1.0 - (diff / (cardWidth * 2))).clamp(0.7, 1.0);
          }
          return Opacity(opacity: opacity, child: child);
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: PoemCard(poem: poems[index]),
        ),
      );
    },
  )
```

---

### A27 — Pull to Refresh
```
Element: Feed, Discover sections — pull down to reload
Visual:  Custom refresh indicator: quill pen icon that rotates while loading
         Background: small sage circle expands and contracts (breathing)
Timing:  Rotation: 800ms loop | Circle pulse: 1200ms loop

Flutter prompt:
  RefreshIndicator(
    color: AppColors.primary,
    backgroundColor: AppColors.primaryContainer,
    displacement: 60,
    strokeWidth: 2.5,
    onRefresh: _refreshFeed,
    child: /* scrollable content */,
  )
  // Custom indicator via RefreshIndicator.adaptive or custom SliverRefreshControl
```

---

### A28 — Audio Player Waveform
```
Element: Inline audio player on poem reader (when audioUrl exists)
Visual:  Static waveform bars (random heights generated from seed)
         While playing: bars animate up/down (±30% height) in sequence
         Progress: left portion fills Primary colour, unplayed stays Outline Variant
         Play/pause button morphs between icons with crossfade
Timing:  Bar animation: staggered 50ms, sine wave pattern, loop

Flutter prompt:
  // Waveform bars:
  Row(
    children: List.generate(40, (i) {
      final baseHeight = _waveHeights[i]; // pre-generated from audio metadata or seed
      return AnimatedContainer(
        duration: Duration(milliseconds: 300 + (i * 15)),
        curve: Curves.easeInOut,
        width: 3,
        height: _isPlaying
          ? baseHeight * (0.5 + 0.5 * sin(_animValue + i * 0.4))
          : baseHeight * 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: _progressFraction > (i / 40)
            ? AppColors.primary
            : AppColors.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }),
  )
```

---

### A29 — Save/Bookmark Toggle
```
Element: Bookmark icon on PoemCard action row and poem reader reaction bar
Visual:  Unsaved → Saved:
           Icon outline fills to solid (bookmark_border → bookmark)
           Colour shifts from onSurfaceVariant to primary
           Small scale pulse: 1.0→1.25→1.0
         Saved → Unsaved: reverse, grey out
Timing:  Scale: 200ms spring | Colour: 150ms

Flutter prompt:
  GestureDetector(
    onTap: _toggleSave,
    child: AnimatedSwitcher(
      duration: AppDurations.quick,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.spring),
        ),
        child: child,
      ),
      child: Icon(
        _isSaved ? Icons.bookmark : Icons.bookmark_border,
        key: ValueKey(_isSaved),
        color: _isSaved ? AppColors.primary : AppColors.onSurfaceVariant,
        size: 20,
      ),
    ),
  )
```

---

### A30 — Username Availability Check Pulse
```
Element: Username field on onboarding username screen
Visual:  While checking: spinning circular indicator (16dp) in suffix
         Available: ✓ icon fades in with green colour + field border turns primary
         Taken: ✗ icon fades in with error colour + field border turns error
         Both entrance: scale 0.5→1.0 + fade, 200ms spring
Timing:  Check delay: debounce 400ms | Indicator: continuous spin | Result: 200ms

Flutter prompt:
  TextField(
    decoration: InputDecoration(
      suffixIcon: AnimatedSwitcher(
        duration: AppDurations.quick,
        child: switch (_availabilityState) {
          AvailabilityState.checking => const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ).animate(key: const ValueKey('checking')),
          AvailabilityState.available => const Icon(Icons.check_circle_outline,
              color: AppColors.success, size: 20,
            ).animate(key: const ValueKey('available'))
             .scale(begin: const Offset(0.5,0.5), curve: AppCurves.spring)
             .fadeIn(),
          AvailabilityState.taken => const Icon(Icons.cancel_outlined,
              color: AppColors.error, size: 20,
            ).animate(key: const ValueKey('taken'))
             .scale(begin: const Offset(0.5,0.5), curve: AppCurves.spring)
             .fadeIn(),
          _ => const SizedBox.shrink(key: ValueKey('idle')),
        },
      ),
    ),
  )
```

---

# PART 3 — COMPONENT LIBRARY

**How to use components:**
- Every component below is a self-contained, reusable widget
- Screen specs in Part 4 reference components by name (e.g. "PoemCard Variant A")
- Each component section includes: visual spec, dimensions, states, Flutter snippet
- Build components once in `lib/widgets/` and reuse — never rebuild inline on screens

**Component index:**
```
3.1  BottomNavigationBar    — 5-tab nav with FAB write button
3.2  PoemCard               — Variants: Standard · Anonymous · Skeleton
3.3  ThoughtCard            — Compact thought with visibility badge
3.4  StoryCard              — Story with cover, genre, part count
3.5  UserCard               — Compact user row for search / follow
3.6  MoodFilterSheet        — Horizontal mood chip scroll (feed filter)
3.7  ContentTypePickerSheet — Write FAB → choose content type
3.8  ReactionPicker         — Emoji reaction bottom sheet
3.9  ConversationListItem   — DM thread row
3.10 MessageBubble          — Chat bubble variants (own / other / shared poem)
3.11 DuelCard               — Head-to-head challenge poem card
3.12 CollabStanzaCard       — Stanza block in collaborative poem
3.13 ToastSnackbar          — Poetic floating notification
3.14 SearchBar              — Focus-aware search input
3.15 OTPInput               — 6-box OTP with auto-advance and error shake
3.16 PoemEditorToolbar      — Sticky formatting toolbar above keyboard
3.17 ContentTypePickerSheet — Write FAB bottom sheet (detail)
```

---

## 3.1 Bottom Navigation Bar

```
┌─────────────────────────────────────────────────────┐
│  Feed    Discover  [✏ FAB]  Alerts   Profile        │
│  ●feed   ○disco    ◉write  ○bell    ○person         │
│  [pill]                                              │
└─────────────────────────────────────────────────────┘

Height: 80dp
Background: Surface (#F6FAF8), tonal elevation Level 4
Top border: 1dp outlineVariant

Standard tabs (Feed, Discover, Alerts, Profile):
  Icon: 24dp, outlined when inactive / filled when active
  Label: labelMedium
  Active: primaryContainer pill indicator 64×32dp, primary text
  Inactive: outline colour icons and labels
  Touch target: full slot width × 80dp

Write FAB (centre slot):
  Diameter: 56dp circle
  Background: Primary (#1F6B5A)
  Icon: edit_outlined or custom quill SVG, 26dp, onPrimary white
  Elevation: Level 3 — slight tonal tint + 2dp ambient shadow
  Position: floating 12dp above nav bar baseline
  Tap: A16 animation

Flutter prompt:
  Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.bottomCenter,
    children: [
      NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        height: 80,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: SizedBox(width: 56),  // FAB placeholder
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      Positioned(
        bottom: MediaQuery.of(context).viewPadding.bottom + 14,
        child: FloatingActionButton(
          onPressed: _openContentPicker,
          backgroundColor: AppColors.primary,
          elevation: 3,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 26),
        ),
      ),
    ],
  )
```

---

## 3.2 PoemCard — All Variants

### Variant A — Standard PoemCard
```
┌──[3dp mood border]──────────────────────────────────────┐
│  [◉ 40dp]  displayName · @user         [time]  [⋮]     │
│  [Mood chip]  [EN chip]                                 │
│                                                         │
│  Poem Title Here (max 2 lines, titleLarge)              │
│                                                         │
│  Preview line one of the poem content here...           │
│  Preview line two continues here across the card...     │
│  Preview line three fades with ellipsis overflow...     │
│  ─────────────────────────────────────────────────      │
│  [🤍 42]    [💬 7]    [👁 128]         [↗]             │
└─────────────────────────────────────────────────────────┘

Dimensions:
  Width: screen - 32dp (full content zone)
  Padding: 16dp all sides
  Corner: 12dp
  Background: Surface (#F6FAF8), Level 1 elevation
  Left border: 3dp, AppColors.mood(moodName).withValues(alpha: 0.8)
  Vertical margin: 6dp between cards

Header row spacing:
  Avatar: 40dp circle
  Avatar to name column: 12dp
  Name column: flex 1
  Timestamp: labelSmall, tertiary
  Menu icon: ⋮ 20dp, 48dp touch target

Chip row:
  Top margin: 8dp
  Chip gap: 6dp
  Mood chip: secondaryContainer bg, moodAccentColor text, 28dp height, 4dp corner
  Language chip: tertiaryContainer bg, onTertiaryContainer text, 28dp height, 4dp corner

Title:
  Top margin: 8dp
  Font: titleLarge, but Playfair if EN / system if BN
  Max lines: 2, ellipsis

Preview:
  Top margin: 4dp
  Font: bodyLarge, Playfair (EN) / system (BN)
  Max lines: 3, ellipsis

Divider: 1dp outlineVariant, top margin 12dp

Action row:
  Top margin: 8dp
  Each action: Row [Icon 20dp, gap 4dp, count labelMedium variant]
  Actions spacing: 16dp between
  Share: right-aligned, no count label
  Touch target: 48×48dp min per action

Tap whole card: navigate to /poem/:id (A06 transition)
Tap avatar/name: navigate to /user/:username
Tap ⋮: bottom sheet with Share / Report / Block
```

### Variant B — Anonymous PoemCard
```
Same as A except:
  Avatar: grey quill icon on primaryContainer bg
  displayName replaced by "Anonymous Poet" in italic
  @username hidden
  ⋮ menu: only Share (no Report/Block)
```

### Variant C — Skeleton PoemCard
```
All content replaced with A03 shimmer rects
Same dimensions as Variant A
Background: Surface, no left border colour (outlineVariant tint)
```

---

## 3.3 ThoughtCard
```
┌────────────────────────────────────────────────────────┐
│  "A thought for the world appears here in body large   │
│   text, up to four lines of content before it is       │
│   truncated with an ellipsis at the end..."            │
│                                                        │
│  [◉ 32dp]  displayName    [🌍 public]     [time]  [😊] │
└────────────────────────────────────────────────────────┘

Background: Surface Variant (#EDF4F0) — NOT Surface
Corner: 12dp
Padding: 16dp
Margin: 6dp vertical, 16dp horizontal
No left mood border

Content:
  Font: bodyLarge
  Max lines: 4
  Top: 0dp (content-first, no header)

Footer row (bottom):
  Avatar: 32dp circle
  Gap: 8dp
  displayName: bodyMedium, onSurface
  Visibility badge:
    public: world icon 14dp, tertiary — no chip needed, minimal
    mutual: 🔒 chip, tertiaryContainer bg, labelSmall
    private: 🔒 chip filled, secondary bg, onSecondary text, labelSmall
  Timestamp: right-aligned, labelSmall, tertiary
  React emoji button: 20dp, right-aligned

Tap card: expands to full thought (no separate screen)
Tap avatar: /user/:username
```

---

## 3.4 StoryCard — Grid Card (used in Discover, Search, Profile Stories tab)

Inspired by modern writing platforms (Wattpad, Royal Road). Portrait aspect ratio — feels like a book cover.

```
┌──────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░ │  ← CachedNetworkImage
│ ░░ Cover Image  ░░░░ │     aspect ratio 2:3 (full card width)
│ ░░░░░░░░░░░░░░░░░░░░ │     blurhash placeholder
│ ░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░ │
│ [Genre chip]         │  ← top-left overlay, 4dp corner
│                      │
│ ░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░ │
│ [Collab 🤝] if collab│  ← bottom-left overlay chip
│ ░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░ │
│ ████████████████████ │  ← gradient scrim: transparent → black 72%
│ "Story Title"        │  ← titleSmall, white, bold, max 2 lines
│ @author  · N parts   │  ← labelSmall, white 70% opacity
└──────────────────────┘
  N reads · mood chip

```

```
Cover image container:
  AspectRatio(aspectRatio: 2/3) — portrait book-cover shape
  ClipRRect(borderRadius: 12dp) wrapping the entire card
  CachedNetworkImage(fit: BoxFit.cover) with blurhash placeholder

Top-left overlay (genre chip):
  Positioned top: 8, left: 8
  Container: inverseSurface bg 80% opacity, 4dp corner, 4/8dp padding
  Text: labelSmall, inverseOnSurface

Collab badge (if isCollab):
  Positioned bottom: 52, left: 8
  "🤝 Collab" chip: secondaryContainer 90% opacity, secondary text, labelSmall

Scrim overlay:
  Positioned bottom: 0, left: 0, right: 0 — height 80dp
  LinearGradient(transparent → Colors.black.withValues(alpha: 0.72))

Title + meta (over scrim):
  Positioned bottom: 8, left: 8, right: 8
  Story title: titleSmall, white, fontWeight w600, max 2 lines
  "@username · N parts": labelSmall, white.withValues(alpha: 0.75)

Below-card row (outside cover, below ClipRRect):
  8dp vertical padding
  Row: [👁 N reads labelSmall tertiary] [spacer] [mood colour dot 6dp + mood labelSmall]
  Stats in tertiary colour, compact

Card interaction:
  InkWell with splash on entire card
  Tap → context.push('/story/:id')
  Long press → share sheet

Grid layout (2 columns):
  GridView.builder, crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 16
  childAspectRatio: 0.52  (tall portrait card including below-card stats)
  padding: EdgeInsets.symmetric(horizontal: 16)
```

---

## 3.4b StoryUpdateCard — Feed Card (used in home feed for new chapter updates)

```
┌───────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────┐   │
│ │ Cover image (180dp height, full width, 12dp top │   │
│ │ corners only)                                   │   │
│ │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │   │
│ │ gradient scrim bottom 0→65%                     │   │
│ │ ┌──────────────────────────────────────────┐    │   │
│ │ │ [Ongoing chip]  [New Chapter pill]       │    │   │
│ │ │ "Story Title"  headlineSmall Playfair    │    │   │
│ │ └──────────────────────────────────────────┘    │   │
│ └─────────────────────────────────────────────────┘   │
│                                                       │
│  [◉ 32dp] @author  ·  [🤝 Collab] if collab          │
│                                                       │
│  "Chapter Title"    titleMedium onSurface             │
│  Part 4 · 6 min read    labelSmall tertiary           │
│  Preview of chapter text across two lines here…      │
│                                                       │
│  ────────────────────────────────────────────────     │
│  [🤍 N]  [💬 N]  [👁 N reads]  [🔖 Save]  [↗]       │
└───────────────────────────────────────────────────────┘

Cover image:
  Height: 180dp, corner: 12dp top only (ClipRRect)
  CachedNetworkImage(fit: BoxFit.cover) with blurhash placeholder
  Scrim: LinearGradient bottom 0→65% black.withValues(alpha: 0.65)

Cover overlay (bottom-left):
  "Ongoing"/"Completed" chip: surface 80% opacity, 4dp corner
  "New Chapter" pill: primaryContainer bg, primary text, 4dp corner
  Story title: headlineSmall Playfair, white, max 2 lines

Card body (padding 12dp sides, 10dp vertical):
  Author row: CircleAvatar 32dp + @username bodySmall + collab chip if applicable
  Chapter title: titleMedium, onSurface, max 2 lines
  Part + read time: "Part 4 · 6 min read" labelSmall tertiary, gap 8dp
  Preview: bodyMedium, 2 lines max, onSurfaceVariant

Action row: Divider + [🤍 N] [💬 N] [👁 N] [🔖] [↗]
  Same pattern as PoemCard — 48dp touch targets

Background: surface, corner: 12dp, margin: 6dp vertical 16dp horizontal
```

---

## 3.5 DuelFeedCard
```
┌───────────────────────────────────────────────────────┐
│      ⚔  DUEL  ·  Theme: "Autumn Longing"             │
│          labelLarge, secondary, centred               │
│                                                       │
│  ┌──────────────────┐  vs  ┌──────────────────┐      │
│  │ Poet A preview   │      │ Poet B preview   │      │
│  │ (bodySmall, 3ln) │      │ (bodySmall, 3ln) │      │
│  │ @poetA  labelSm  │      │ @poetB  labelSm  │      │
│  └──────────────────┘      └──────────────────┘      │
│                                                       │
│  [Primary bar ████████░░░░░░░░░░░  68%]              │
│  [Secondary bar ████░░░░░░░░░░░░░░  32%]             │
│                                                       │
│  [FilledButton "Cast your vote"]  [🕐 23h left]      │
└───────────────────────────────────────────────────────┘

Header: ⚔ icon 16dp, "DUEL" labelLarge secondary, theme in tertiary text

Two-column poem preview:
  Width per column: (contentZone - 8dp gap) / 2 = 160dp
  Background: surfaceVariant, 8dp corner, 12dp padding
  Content: 3 lines bodySmall, @author labelSmall tertiary

Progress bars: A11 animation
  Height: 6dp, corner 4dp
  Challenger: primary colour
  Challengee: secondary colour

Vote button: full-width FilledButton, 40dp height
  Already voted: OutlinedButton showing "Voted" instead
  Button disabled after voting

Timer chip: errorContainer bg, error text, labelSmall
  "23h left" — shows remaining time until duel ends

After-vote: percent text appears beside each bar, animated count-up
```

---

## 3.6 CollabFeedCard
```
┌──────────────────────────────────────────────────────┐
│  [🤝 Collaborative]  [✦ Live — 3 poets writing]     │
│                                                      │
│  "Collaborative Poem Title"                          │
│  headlineSmall Playfair                              │
│                                                      │
│  First stanza preview text here across              │
│  two lines of the opening lines...                  │
│  — a second voice adds here, italicised             │
│                                                      │
│  [◉◉◉ +2]  3 contributors  [open/closed badge]     │
│  ────────────────────────────────────────────────   │
│  [🤍 15]   [💬 4]   [👁 89]          [↗ Share]     │
└──────────────────────────────────────────────────────┘

Header badges:
  "🤝 Collaborative": secondaryContainer chip, secondary text, labelMedium
  "✦ Live": success green chip with A12 pulse dot (only when channel active)

Title: headlineSmall Playfair, max 2 lines

Stanza previews:
  Each stanza attributed with a colour strip on left (3dp, author's assigned colour)
  Max 2 stanza previews shown
  Second stanza voice: italic style, slightly indented

Contributors row:
  Overlapping avatars: 28dp each, -8dp overlap, max 3 shown + "+N" badge
  "N contributors" labelSmall tertiary

Status badge:
  Open: secondaryContainer bg, "Open to stanzas" labelSmall
  Closed: tertiaryContainer bg, "Completed" labelSmall
```

---

## 3.7 VideoFeedItem Card (vertical feed)
```
Full-screen Stack:
  ┌────────────────────────────────────────┐  screen height
  │                                        │
  │  [VideoPlayer — full screen cover]     │
  │                                        │
  │ ┌── Top gradient h:160 ──────────────┐ │
  │ │  [← 48dp]    "For You · Following" │ │  ← SafeArea
  │ └────────────────────────────────────┘ │
  │                                        │
  │                          [◉ 48dp] ➕   │  ← right col
  │                          [❤ 42   ]    │    bottom:120
  │                          [💬 7    ]    │    gap: 24dp
  │                          [🔖     ]    │    icons: 28dp
  │                          [↗      ]    │    all white
  │                                        │
  │ ┌── Bottom gradient h:260 ───────────┐ │
  │ │ @displayName  titleMedium white    │ │
  │ │ "Poem title"  headlineSmall Playfair│ │
  │ │  white                             │ │
  │ │ Two-line snippet bodyMedium 80%    │ │
  │ │ white opacity                      │ │
  │ │ [Mood chip 70% opacity]            │ │
  │ └────────────────────────────────────┘ │
  └────────────────────────────────────────┘

Play/pause area: full screen GestureDetector (excludes right column)
  Tap: 48dp semi-transparent white circle appears centre, fades 400ms

Right action column:
  Each icon: 28dp white
  Each label: labelSmall white
  Follow button (on avatar): + badge if not following, animated A07
  All actions: 48×48dp touch target minimum

For You / Following toggle:
  Two text labels side by side
  Active: white, bodyMedium, underline
  Inactive: white.withValues(alpha: 0.6)
  Tap: crossfade 150ms
```

---

## 3.8 Notification List Item
```
┌──────────────────────────────────────────────────────┐
│  [●  ]  [◉ 40dp]  "Riya paused on your poem         │
│  unread          tonight."  bodyMedium onSurface     │
│  dot             · 3h ago   labelSmall tertiary      │
└──────────────────────────────────────────────────────┘

Height: 72dp minimum
Padding: 16dp horizontal, 12dp vertical
Background: surfaceVariant if unread | surface if read

Unread indicator: 8dp Primary circle, left of avatar, vertically centred
  Fades out on tap (read state)

Avatar: 40dp with notification type icon overlay:
  poem_liked → ❤️ 16dp badge, primary bg
  new_follower → 👤 16dp badge, secondary bg
  comment → 💬 16dp badge, secondary bg
  duel → ⚔ 16dp badge, error bg

Message text:
  Bold author name + regular poetic message
  e.g.: "[Riya]bold [paused on your poem tonight.]regular"

Timestamp: labelSmall, tertiary, right-aligned

Tap: navigate to relevant content screen
Swipe left: mark as read (Dismissible)
```

---

## 3.9 Conversation List Item
```
┌──────────────────────────────────────────────────────┐
│  [◉ 48dp]  displayName    titleSmall  [time labelSm] │
│            Last message preview bodySmall variant    │
│            [● 3 unread badge if unread]              │
└──────────────────────────────────────────────────────┘

Height: 72dp
Padding: 16dp
Avatar: 48dp circle
Unread badge: 20dp Primary circle with count, right side
Unread: displayName in medium weight, preview bold
Read: both regular weight
Swipe left: archive or delete (Dismissible, red bg)
```

---

## 3.10 Message Bubble (Own + Other)
```
Own message (right-aligned):
  ┌────────────────────────────────────┐
  │                     Message text  │  ← Primary bg, onPrimary text
  └──────────────────────────────────◣┘  ← pointed corner bottom-right

Other message (left-aligned):
  ┌◢────────────────────────────────┐
  │  Message text                   │  ← Surface bg, onSurface text
  └─────────────────────────────────┘

Own:
  Background: Primary (#1F6B5A)
  Text: onPrimary white, bodyLarge
  Margin: right 16dp, left 64dp
  Corner: topLeft 16dp, topRight 16dp, bottomLeft 16dp, bottomRight 4dp

Other:
  Background: Surface (#F6FAF8)
  Text: onSurface, bodyLarge
  Margin: left 16dp, right 64dp
  Corner: topLeft 4dp, topRight 16dp, bottomLeft 16dp, bottomRight 16dp

Poem share card (inline in bubble):
  surfaceVariant bg, 8dp corner, 12dp padding, 240dp wide
  Title titleSmall + excerpt bodySmall 2 lines + author labelSmall + primary link
  Left: 4dp primary accent border

Timestamp: centred between groups, labelSmall tertiary
  Only shown when gap > 30 minutes between messages
```

---

## 3.11 Audio Player Card
```
┌──────────────────────────────────────────────────────┐
│  [▶/⏸ 48dp]  ▁▂▅▃▇▄▂▆▃▅▁▂▄▆▃▅▂▃▄▆  [2:34 / 4:12]  │
└──────────────────────────────────────────────────────┘

Background: surfaceVariant
Corner: 12dp
Padding: 12dp
Height: 56dp

Play/pause: 48dp circular IconButton, primary colour
Waveform: A28 animation — 40 bars, 3dp wide, 1dp gap
  Filled (played): Primary colour
  Unfilled: Outline Variant
  Height per bar: 8–32dp randomised from seed

Timestamp: labelSmall, tertiary, right-aligned
Progress: tap anywhere on waveform to seek

Tap card: expands to fullscreen audio player modal (sheet)
```

---

## 3.12 Empty State Component
```
┌────────────────────────────────────┐
│             (48dp top)             │
│      [Icon 64dp, outlineVariant]   │
│                                    │
│      Headline (headlineSmall       │
│      Playfair, centred)            │
│                                    │
│      Body text up to 280dp wide    │
│      (bodyMedium variant, centred) │
│                                    │
│      [FilledButton — optional]     │
│             (24dp bottom)          │
└────────────────────────────────────┘

Entrance: A19 staggered (icon → headline → body → button, 100ms each)
Never use generic copy — always use poetic strings from knowledge.md

Per-screen empty states:
  Feed (no follows):     icon: auto_stories_outlined
  Feed (error):          icon: wifi_off_outlined
  Search (no results):   icon: search_off_outlined
  Notifications:         icon: notifications_none_outlined
  DMs:                   icon: chat_bubble_outline_outlined
  Drafts:                icon: description_outlined
  Profile thoughts tab:  icon: format_quote_outlined
  Video feed:            icon: videocam_off_outlined
```

---

## 3.13 Snackbar / Toast
```
Background: Inverse Surface (#2A312D)
Text: Inverse On Surface (#EDF4F0), bodyMedium, 16dp left pad
Height: 52dp minimum, 2-line max
Corner: 4dp
Position: floating, 16dp above bottom nav
Duration: 3000ms auto-dismiss
Dismiss: swipe down gesture

Entrance: slides up 16dp + fades in, 350ms sheetOpen curve
Exit: fades out + slides down, 250ms

Types:
  Default: inverseSurface bg (for general messages)
  Success: success (#16A34A) bg, white text (for publish, save confirmations)
  Error: error (#B3261E) bg, white text (only for critical failures)

Never use: generic "Success", "Error", "Done" — always poetic copy
```

---

## 3.14 Search Bar
```
Height: 56dp
Corner: 8dp (small)
Background: surfaceVariant resting | surface when focused
Border: none resting | 2dp primary on focus
Leading icon: search 20dp, onSurfaceVariant → primary on focus
Placeholder: "Search poems, poets, moods…" italic Playfair, onSurfaceVariant
Clear button (×): 20dp icon, fades in when text > 0, 150ms
Trailing: filter icon 20dp (optional, opens MoodFilterSheet)

Focus animation: border 2dp primary expands from leading icon outward, 200ms
Clear appears: fadeIn + scaleIn 0.7→1.0, 150ms
```

---

## 3.15 OTP Input (6-Box)
```
Row of 6 boxes, centred, gap 8dp each
Each box: 48dp wide × 58dp tall

Box states:
  Idle: 1.5dp outlineVariant border, surface bg
  Focused: 2dp primary border, scale 1.04, surfaceVariant bg tint
  Filled: 1.5dp outline border, surfaceVariant bg
  Error: 2dp error border all 6 boxes + A17 shake

Auto-advance: digit entered → focus moves to next box instantly
Auto-submit: all 6 filled → onComplete fires after 100ms delay
Backspace: clears current box → moves focus to previous

Keyboard type: number-pad
Max length per box: 1 character
```

---

## 3.16 Poem Editor Toolbar
```
Height: 48dp
Background: surface + Level 2 elevation
Position: sticky — sits just above keyboard (bottom: MediaQuery.viewInsets.bottom)
Top border: 1dp outlineVariant

Buttons (left to right):
  [B bold]  [I italic]  [→ indent]  [— stanza break]  [🖼 image]  |  [🪄 AI] (PostHog flag)

Each button: 48×48dp touch target, icon 20dp, onSurfaceVariant
Active (B/I): AnimatedContainer bg fills to primaryContainer, icon becomes primary, 4dp corner

Divider before AI: 1dp outlineVariant vertical, 24dp height

"Saved" indicator: labelSmall, tertiary, absolute top-right of toolbar
  Animates: fadeIn 200ms → stays 2s → fadeOut 200ms
```

---

## 3.17 Content Type Picker Sheet (Write FAB tap)
```
Sheet: lg corners, surface bg, 50% screen height

Handle: standard 32×4dp pill

Header: "What would you like to create?" titleMedium, centred, 16dp top + 16dp bottom

Options (ListTile 56dp each):
  ┌──────────────────────────────────────────────────┐
  │  ✍️  [icon 24dp]  Write a Poem       [>chevron] │
  │  📖              Start a Story       [>chevron] │
  │  💭              Share a Thought     [>chevron] │
  │  ➕              Add a Story Part    [>chevron] │  ← only if active stories exist
  └──────────────────────────────────────────────────┘

Each item:
  Icon: 24dp in a 40dp rounded square, primaryContainer bg, primary icon
  Label: titleSmall, onSurface
  Chevron: 20dp, onSurfaceVariant

"Add Story Part" conditional: if user.activeStories.isEmpty → hidden entirely
  When shown: secondary colour icon bg instead of primary

Sheet entrance: A04 animation
Item tap: sheet closes (A04 reverse) → navigate
```

---

# PART 4 — ALL SCREENS — COMPLETE GRID LAYOUTS

**How to read screen specs:**
- Each screen has a route path (e.g. `/auth/welcome`), used in go_router
- `Background:` → find the implementation snippet in Section 1.7
- ASCII grids show the layout — every element, gap, and alignment
- `Animations:` → look up each ID in Section 2.3 for the Flutter implementation
- Sections labelled `[POST-MVP]` must NOT be built until the MVP ships to real users

**Screen index:**
```
Auth flow (01–06):
  01 Welcome            /auth/welcome
  02 Sign Up            /auth/sign-up
  03 Verify OTP         /auth/verify-otp
  04 Onboarding Name    /auth/onboarding/name
  05 Onboarding Genres  /auth/onboarding/genres
  06 Sign In            /auth/sign-in

Main app (07–25):
  07 Feed               /feed
  08 Poem Reader        /poem/:id
  09 Poem Editor        /write/poem (new) · /write/poem/:id (edit)
  10 Story Reader       /story/:id
  11 Story Part Reader  /story/:id/part/:partId
  12 Discover           /discover
  13 Search Results     /search
  14 Profile (own)      /profile
  15 Profile (other)    /user/:username
  16 Edit Profile       /profile/edit
  17 Notifications      /notifications
  18 Video Feed         /video
  19 Duel               /duel/:id
  20 Collab Poem        /collab/:id
  21 Story Editor       /write/story (new) · /write/story/:id (edit)
  22 Thought Composer   /write/thought
  23 Messages List      /messages
  24 Message Thread     /messages/:conversationId
  25 Drafts             /write/drafts
```

---

## Screen 01 — Welcome (`/auth/welcome`)

```
Background: BG-02 (sage radial glow + faint circles)

Grid: Single column, 24dp horizontal margins

┌─ Status bar (system) ────────────────────────────────┐
│                                                      │
│              flex: 2 spacer                          │
│                                                      │
│   ┌──────────────────────────────────────────────┐   │
│   │         [Quill SVG 80×80dp]                  │   │
│   │         Primary (#1F6B5A) colour             │   │
│   │         centred, drop — no shadow            │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│              24dp gap                               │
│                                                      │
│   ┌──────────────────────────────────────────────┐   │
│   │   "Verso"                              │   │
│   │   displayLarge · Playfair 700 · onSurface    │   │
│   │   centre-aligned                             │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│              8dp gap                                │
│                                                      │
│   ┌──────────────────────────────────────────────┐   │
│   │   "Where words find their world."            │   │
│   │   bodyLarge · italic · DM Sans · variant     │   │
│   │   centre-aligned                             │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│              flex: 3 spacer                          │
│                                                      │
│   ┌──────────────────────────────────────────────┐   │
│   │  [FilledButton full-width 56dp]              │   │
│   │  "Begin your story"                          │   │
│   │  Primary bg · labelLarge · 8dp corner        │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│              12dp gap                               │
│                                                      │
│   ┌──────────────────────────────────────────────┐   │
│   │  "Already a poet? Sign in"                   │   │
│   │  TextButton · bodyMedium · Primary colour    │   │
│   │  centred                                     │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│              safe bottom (16dp + system)            │
└──────────────────────────────────────────────────────┘

Animations:
  On screen mount — A20 staggered entrance
  CTA button tap — A16-style press compress + A06 navigation
```

---

## Screen 02 — Sign Up (`/auth/sign-up`)

```
Background: BG-02

Grid: Auth card centred (BG-06 card wrapper)

AppBar: none — back arrow only (IconButton top-left, 48dp, outside card)

┌─ Auth card (margin 24dp horizontal, centred vertical) ─┐
│                                                         │
│   "Create your account"                                 │
│   headlineSmall · Playfair                              │
│                                                         │
│   24dp gap                                              │
│                                                         │
│   ┌─ Email TextField ──────────────────────────────┐   │
│   │  56dp height · sm corner · emailAddress type   │   │
│   │  Leading: email_outlined icon 20dp             │   │
│   │  Placeholder: "your@email.com"                 │   │
│   └────────────────────────────────────────────────┘   │
│                                                         │
│   16dp gap                                              │
│                                                         │
│   ┌─ Password TextField ───────────────────────────┐   │
│   │  56dp · obscureText · show/hide toggle suffix  │   │
│   │  Leading: lock_outline icon 20dp               │   │
│   │  Placeholder: "At least 8 characters"          │   │
│   └────────────────────────────────────────────────┘   │
│                                                         │
│   8dp gap                                               │
│                                                         │
│   Error text (if any): bodySmall · error colour        │
│                                                         │
│   24dp gap                                              │
│                                                         │
│   ┌─ FilledButton ─────────────────────────────────┐   │
│   │  "Begin your story" · full width · 56dp        │   │
│   │  Loading: CircularProgressIndicator 20dp white │   │
│   └────────────────────────────────────────────────┘   │
│                                                         │
│   16dp gap                                              │
│                                                         │
│   "Already a poet? Sign in" centred TextButton         │
│                                                         │
└─────────────────────────────────────────────────────────┘

Interaction animations:
  Email/Password focus: A (border primary fill, 200ms)
  Password show/hide toggle: icon crossfade 150ms AnimatedSwitcher
  Submit loading: button text fades, spinner fades in simultaneously
  Error: A17-style shake on email/password fields, 400ms
```

---

## Screen 03 — Verify OTP (`/auth/verify-otp`)

```
Background: BG-02

AppBar: ← back (minimal, no title)
Content: Column centred, 24dp horizontal padding

┌──────────────────────────────────────────────────────┐
│                                                      │
│  48dp top                                            │
│                                                      │
│  "Check your email"                                  │
│  headlineSmall · Playfair · centred                  │
│                                                      │
│  16dp gap                                            │
│                                                      │
│  "We sent a 6-digit code to"                         │
│  bodyMedium · variant · centred                      │
│  "user@email.com"                                    │
│  bodyMedium · primary · semibold · centred           │
│                                                      │
│  32dp gap                                            │
│                                                      │
│  [OTP Input — 6 boxes] ← A17 interactions            │
│  centred, 8dp gap between boxes                     │
│                                                      │
│  24dp gap                                            │
│                                                      │
│  [FilledButton "Verify code" full-width 56dp]        │
│  disabled until all 6 digits filled                  │
│                                                      │
│  20dp gap                                            │
│                                                      │
│  Resend row:                                         │
│  "Didn't get it?"  bodySmall variant                 │
│  [TextButton "Resend code"]  primary                 │
│  When countdown active: "Resend in 0:45" tertiary    │
│                                                      │
│  12dp gap                                            │
│                                                      │
│  [TextButton "Change email"]  variant                │
│  → navigates back to sign-up                        │
│                                                      │
└──────────────────────────────────────────────────────┘

Animations:
  A17: focus boxes, error shake
  Resend countdown: AnimatedSwitcher between timer and button
  Verify button: pulse glow when all 6 filled (A09 style, 300ms)
  Wrong code: all boxes red border + shake + "Incorrect code" error text fades in
```

---

## Screen 04 — Sign In (`/auth/sign-in`)

```
Background: BG-02

Auth card (BG-06)

┌─ Auth card ─────────────────────────────────────────┐
│                                                     │
│  "Welcome back."                                    │
│  headlineSmall · Playfair                           │
│                                                     │
│  "Your words have been waiting."                    │
│  bodyLarge · italic · variant                       │
│                                                     │
│  24dp gap                                           │
│                                                     │
│  [Email TextField 56dp]                             │
│                                                     │
│  16dp gap                                           │
│                                                     │
│  [Password TextField 56dp + show/hide]              │
│                                                     │
│  8dp gap                                            │
│                                                     │
│  "Forgot password?" right-aligned TextButton        │
│  bodySmall · primary                                │
│                                                     │
│  24dp gap                                           │
│                                                     │
│  [FilledButton "Return to your page" full-width]    │
│                                                     │
│  16dp gap                                           │
│                                                     │
│  "New to Verso?  Begin your story"            │
│  bodyMedium centred · primary TextButton            │
│                                                     │
└─────────────────────────────────────────────────────┘

Special state — EMAIL_NOT_VERIFIED:
  Snackbar: "Please verify your email. A new code has been sent."
  Error type: Snackbar (not inline)
  → navigate to /auth/verify-otp passing email

Error state — wrong password:
  Inline error text below password field
  bodySmall · error colour · fade in 200ms
```

---

## Screen 05 — Forgot Password (`/auth/forgot-password`)

```
Background: BG-02, no auth card — full screen layout

AppBar: ← back (minimal)
Content: Column, 24dp margins

"Lost your way?"            ← headlineSmall Playfair, 48dp top
"Enter your email and we'll send you a reset code."
                            ← bodyMedium variant, 12dp below

32dp gap

[Email TextField 56dp]

24dp gap

[FilledButton "Send reset code" full-width]

────────────────────────────────────

After 200 response (success):
  Screen transitions to OTP screen with mode: 'reset'
  On OTP verified in reset mode:
    New password input appears (animated slideDown + fadeIn, 350ms)
    "New password" TextField + confirm
    [FilledButton "Reset password"]
    On success → snackbar "Password reset. Please sign in." → /auth/sign-in
```

---

## Screen 06 — Onboarding: Username (`/auth/onboarding/username`)

```
Background: BG-02

No AppBar — progress indicator at top instead:
  Row of 3 dots: filled primary, outline, outline (step 1 of 3)
  Dots: 8dp circle each, 6dp gap, centred, 24dp from top

Content: Column centred, 24dp margins

48dp from progress indicator

"Choose your pen name"
headlineSmall · Playfair

12dp gap

"This is how the world will know you."
bodyMedium · italic · variant · centred

32dp gap

┌─ Username TextField 56dp ───────────────────────────┐
│  Prefix text: "@" bodyLarge primary                 │
│  Placeholder: "yourname"                            │
│  Input type: text · autocorrect off                 │
│  Suffix: A30 availability indicator                 │
└─────────────────────────────────────────────────────┘

8dp gap

Availability feedback text (bodySmall, animated fadeIn):
  Available: "✓ This name is available" · success colour
  Taken: "✗ This name is taken" · error colour
  Rule hint: "3–20 characters · letters, numbers, underscore only"
             bodySmall · tertiary · always shown

32dp gap

[FilledButton "This is my name" full-width 56dp]
disabled until: username valid + available

16dp gap

[TextButton "I'll choose later" variant]
```

---

## Screen 07 — Onboarding: Moods (`/auth/onboarding/moods`)

```
Background: BG-02

Progress: dots step 2 of 3, 24dp from top

"What moves you?"       headlineSmall Playfair, 48dp from progress
"Choose up to 3 moods to shape your feed."  bodyMedium variant, 12dp below

24dp gap

GridView — 2 columns, 12dp gap between cells, 16dp horizontal margins
Each mood card: 160dp wide, 80dp tall

┌──────────────┐  ┌──────────────┐
│  [emoji 28dp]│  │  [emoji 28dp]│
│  Mood Name   │  │  Mood Name   │
└──────────────┘  └──────────────┘

Card design:
  LinearGradient: [moodColor.withValues(alpha: 0.65), moodColor.withValues(alpha: 0.3)]
  direction: topLeft → bottomRight
  Corner: 12dp
  Shadow: none — gradient provides depth

Card content:
  emoji: 28dp, centred top-third
  name: titleSmall, white, centred bottom-third

Selected state: A10 animation
Max 3: 4th tap deselects oldest

32dp gap (after grid)

[FilledButton "These are my moods" full-width]
disabled until ≥ 1 mood selected

12dp gap

[TextButton "I'll decide later" variant · centred]
```

---

## Screen 08 — Onboarding: Language (`/auth/onboarding/language`)

```
Background: BG-02

Progress: dots step 3 of 3

"What language do you write in?"
headlineSmall Playfair, 48dp from progress

12dp gap

"This shapes what content you'll see in your feed."
bodyMedium variant centred

32dp gap

Column of 3 RadioCards, 12dp gap:

Each card: 56dp tall, full content width, 12dp corner
  ┌────────────────────────────────────────────────────┐
  │  ◉ / ○  [Language icon 20dp]  "English"  labelLg  │
  └────────────────────────────────────────────────────┘

States:
  Selected: primaryContainer bg + 2dp primary border, primary radio dot
            AnimatedContainer 150ms fill
  Unselected: surface bg + 1dp outlineVariant border, outline radio

Options: "English" | "বাংলা" | "Both"

বাংলা label: Noto Serif Bengali (system) — no fontFamily override

32dp gap

[FilledButton "Take me to my feed" full-width]
disabled until selection made

Tap → PUT /api/users/me/onboarding → navigate to /feed with A06 transition
```

---

## Screen 09 — Feed (`/feed`)

```
Background: BG-01 (clean vellum)

CustomScrollView:
┌─ Status bar ────────────────────────────────────────┐
│                                                     │
│  SliverAppBar (floating, snap, 56dp)                │
│  ┌───────────────────────────────────────────────┐  │
│  │  [🪶 icon 20dp]  "Verso"  titleLarge   │  │
│  │  primary                   [🔔 A13] [🔍]    │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  SliverPersistentHeader (pinned, 48dp)              │
│  ┌─ Filter Bar ──────────────────────────────────┐  │
│  │  ← horizontal scroll, 16dp left pad →        │  │
│  │  [All] [Following] [Poems] [Stories]          │  │
│  │  [Thoughts] [🎭 Mood]                        │  │
│  │  Gap: 8dp · chip h: 32dp · A05 animation    │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  SliverList — feed items:                           │
│                                                     │
│    8dp top padding                                  │
│    PoemCard (Variant A/B/C)   ← A19 entrance       │
│    6dp gap                                          │
│    ThoughtCard                                      │
│    6dp gap                                          │
│    StoryUpdateCard                                  │
│    6dp gap                                          │
│    DuelFeedCard                                     │
│    6dp gap                                          │
│    CollabFeedCard                                   │
│    6dp gap                                          │
│    … infinite scroll …                              │
│    80dp bottom padding (nav clearance)             │
│                                                     │
│  Empty state: Empty State Component (Section 3.12) │
│                                                     │
├─ Bottom Navigation Bar (80dp) ─────────────────────┤
└─────────────────────────────────────────────────────┘

Mood Filter Sheet (triggered by 🎭 chip):
  DraggableScrollableSheet initial 0.45, max 0.75
  Title "Filter by mood" titleMedium
  GridView 2-col of mood chips (full variant, A10 interactions)
  [Apply filters FilledButton] [Clear TextButton]

Pull to refresh: A27 animation
```

---

## Screen 10 — Poem Editor (`/write`)

```
Background: BG-03 (pure vellum — maximum breathing room)
resizeToAvoidBottomInset: true

┌─ Status bar ────────────────────────────────────────┐
│                                                     │
│  AppBar (56dp, no elevation, surface bg)            │
│  ┌───────────────────────────────────────────────┐  │
│  │  [← 48dp]  "New Poem" titleMedium  [EN|BN]   │  │
│  │                               [Publish btn]   │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  Content area (padding: 24dp horizontal, 16dp top)  │
│                                                     │
│  ┌─ Title input ─────────────────────────────────┐  │
│  │  "A title for your verse…"                    │  │
│  │  titleLarge Playfair (EN) / system (BN)       │  │
│  │  No border resting                            │  │
│  │  Focus: 2dp Primary underline fades in 200ms  │  │
│  │  Height: auto (single line, no maxLines)      │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  12dp gap                                           │
│                                                     │
│  1dp outlineVariant divider (full width)           │
│                                                     │
│  12dp gap                                           │
│                                                     │
│  Expanded text area (fills remaining screen)        │
│  ┌─ Poem body ───────────────────────────────────┐  │
│  │  "Begin here…" italic placeholder             │  │
│  │  EN: englishPoem style (Playfair 18sp/32lh)   │  │
│  │  BN: banglaPoem style (system 18sp/38lh)      │  │
│  │  cursorColor: Primary  cursorWidth: 2dp       │  │
│  │  A01 cursor pulse                             │  │
│  │  No border, expands downward                  │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  Mood/Tags row (below poem, above keyboard):        │
│  [+ Add mood]  [+ Add tags]  (labelMedium primary)  │
│  Tapping opens MoodTagSheet (A04)                  │
│                                                     │
├─ Toolbar (48dp, above keyboard) ──────────────────┤
│  [B] [I] [→] [—] [🖼]  |  [🪄]                   │
└─────────────────────────────────────────────────────┘

EN|BN SegmentedButton:
  Width: 80dp, height: 32dp, 8dp corner
  Active: primaryContainer bg, primary text
  Inactive: surfaceVariant, variant text
  Transition: 150ms AnimatedContainer fill

Publish button:
  Height: 36dp, padding: 16dp horizontal
  Disabled: outlineVariant bg, variant text
  Enabled: primary bg, white text (AnimatedContainer 250ms)
  Loading state: inline CircularProgress 16dp replaces text

Auto-save:
  Debounce 3000ms after last keystroke
  PUT /api/drafts/:id
  "Saved" label appears top-right of toolbar (A: fadeIn 200ms, stays 2s, fadeOut 200ms)

Drafts list (back button → confirm sheet if unsaved):
  "Save draft?" sheet with Save / Discard / Cancel options
```

---

## Screen 11 — Poem Reader (`/poem/:id`)

```
Background: BG-03
extendBodyBehindAppBar: true

┌─ Status bar (light icons over content) ────────────┐
│                                                    │
│  AppBar (transparent, 56dp)                        │
│  ┌────────────────────────────────────────────┐   │
│  │  [← 48dp]                        [↗ share]│   │
│  │  icons: onSurface or white depending on bg │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  SingleChildScrollView                             │
│                                                    │
│   padding: EdgeInsets.fromLTRB(24, 88, 24, 80)    │
│                                                    │
│   "Poem Title"                                     │
│   headlineLarge · Playfair 600 · onSurface        │
│   max width 640dp (tablet-safe, centred on wide)  │
│                                                    │
│   16dp gap                                         │
│                                                    │
│   Row: [◉ 32dp]  displayName  ·  timestamp        │
│        bodyMedium  ·  labelSmall tertiary          │
│        avatar: tap → /user/:username               │
│                                                    │
│   12dp gap                                         │
│                                                    │
│   Horizontal chip scroll:                          │
│   [Mood chip]  [Language chip]  [Genre chip?]     │
│   SingleChildScrollView, showsHorizontalScrollIndicator: false│
│                                                    │
│   16dp gap                                         │
│                                                    │
│   1dp outlineVariant divider                       │
│                                                    │
│   24dp gap                                         │
│                                                    │
│   Poem body:                                       │
│   EN → AppTypography.englishPoem                  │
│   BN → AppTypography.banglaPoem                   │
│   line breaks preserved                            │
│                                                    │
│   Stanza breaks: centred " — " + 24dp above/below │
│                                                    │
│   32dp gap                                         │
│                                                    │
│   [AudioPlayer card — if audioUrl exists]          │
│   → Section 3.11, full width                      │
│                                                    │
│   [Video chip — if videoUrl exists]                │
│   OutlinedButton "▶ Watch recitation"             │
│   → context.push('/video-feed')                   │
│     // poemId scroll-to handled via Riverpod state │
│                                                    │
│   80dp bottom padding                              │
│                                                    │
├─ Reaction Bar (sticky bottom 64dp) ───────────────┤
│  Surface bg · Level 2 elevation · outlineVariant  │
│  top border 1dp                                    │
│  ┌────────────────────────────────────────────┐   │
│  │  [❤ Like N]  [💬 N]  [🔖]      [↗ Share]  │   │
│  │  48dp each touch target · gap: evenly      │   │
│  └────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────┘

Interactions:
  Like: A02 heart spring burst
  Save: A29 bookmark toggle
  Comment: A04 opens CommentSheet at 50% height
  Share: system share sheet (Share.share())
  Read tracking: Timer(5s) → POST /api/poems/:id/read on mount
```

---

## Screen 12 — Discover (`/discover`)

```
Background: BG-01

CustomScrollView:
┌─ Status bar ────────────────────────────────────────┐
│                                                     │
│  SliverAppBar (expandedHeight: 120dp)               │
│  Collapsed: search icon + title                     │
│  Expanded:                                          │
│  ┌───────────────────────────────────────────────┐  │
│  │  "Discover"  headlineSmall Playfair           │  │
│  │  ┌─ Search Bar (56dp) ─────────────────────┐  │  │
│  │  │ 🔍  "Search poems, poets, moods…"       │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  SliverPersistentHeader (pinned, 48dp):             │
│  Language toggle [All] [English] [বাংলা]             │
│  SegmentedButton full-content-width                 │
│                                                     │
│  SliverList content:                                │
│                                                     │
│  ── "Trending Poems" section ──────────────────     │
│  Row header: titleLarge + "See all →" labelLarge    │
│  primary right-aligned                              │
│  Horizontal ListView snap scroll (A26):             │
│    PoemCard 262dp (80% width), 8dp gap             │
│    First: 16dp left padding, last: 16dp right       │
│                                                     │
│  24dp section gap                                   │
│                                                     │
│  ── "New Stories" section ─────────────────────     │
│  Row header                                         │
│  GridView 2-col, 8dp gap, 160dp card height:       │
│  ┌──────────┐  ┌──────────┐                        │
│  │ Story    │  │ Story    │  story cover cards     │
│  │ cover    │  │ cover    │                        │
│  └──────────┘  └──────────┘                        │
│                                                     │
│  24dp section gap                                   │
│                                                     │
│  ── Video banner ──────────────────────────────     │
│  Full-width card 200dp:                             │
│  Primary bg + white gradient overlay               │
│  "🎥 Poets in Motion →" titleLarge white           │
│  Subtitle: "Watch poem recitations" bodyMedium     │
│  Tap → /video-feed                                  │
│                                                     │
│  24dp section gap                                   │
│                                                     │
│  ── "Mood Collections" section ─────────────────    │
│  Row header                                         │
│  Wrap of mood chips (3 per row max):               │
│  Each chip 104dp wide × 40dp tall, mood gradient   │
│  background, white emoji + text                    │
│  Tap → feed filtered by that mood                  │
│                                                     │
│  24dp section gap                                   │
│                                                     │
│  ── "Writers to Follow" section ────────────────    │
│  Row header                                         │
│  Horizontal ListView (no snap):                    │
│  UserCard 120dp wide × 160dp tall:                 │
│  ┌──────────┐                                       │
│  │ [◉ 56dp] │  avatar centred top                  │
│  │ Name     │  titleSmall centred                  │
│  │ @user    │  bodySmall variant centred            │
│  │ 42 poems │  labelSmall tertiary centred          │
│  │ [Follow] │  outlined button 32dp                │
│  └──────────┘                                       │
│                                                     │
│  80dp bottom padding                               │
└─────────────────────────────────────────────────────┘
```

---

## Screen 13 — Search Results (`/discover/search`)

```
Background: BG-01

AppBar: search bar (focused, primary border, back button replaces search icon)

Tab bar below AppBar (pinned):
  [All] [Poems] [Stories] [Poets] [Tags]
  TabBar with pill indicator A18 animation

Tab content (TabBarView):

  All tab: mixed results, SliverList
  Poems tab: PoemCard list
  Stories tab: 2-col grid of StoryCards
  Poets tab: ListView of UserCards (horizontal compact)
  Tags tab: Wrap of tag chips → tap to filter feed

Empty state per tab:
  "No poems found. The silence holds its own poetry."
  "No stories found. Every great story begins with a single line."
  etc. from knowledge.md

Loading: staggered A03 skeleton cards
```

---

## Screen 14 — Own Profile (`/profile`)

```
Background: BG-01

NestedScrollView:
┌─ Status bar (light, transparent over cover) ───────┐
│                                                    │
│  SliverAppBar (expandedHeight: 200dp)              │
│  ┌─ Cover photo 200dp (CachedNetworkImage) ─────┐  │
│  │ Gradient scrim: transparent→black 55% bottom │  │
│  │ [✏ edit 48dp touch, absolute top-right 12dp] │  │
│  └───────────────────────────────────────────────┘  │
│                                                    │
│  SliverToBoxAdapter:                               │
│                                                    │
│  Profile header section:                           │
│  ┌──────────────────────────────────────────────┐  │
│  │  [Avatar 80dp] ← translateY: -40dp           │  │
│  │  3dp Surface ring                            │  │
│  │  [✓ verified badge 20dp if poet]             │  │
│  │                                              │  │
│  │  16dp gap (from avatar baseline)             │  │
│  │                                              │  │
│  │  displayName  headlineSmall Playfair         │  │
│  │  @username    bodyMedium variant             │  │
│  │                                              │  │
│  │  8dp gap                                     │  │
│  │                                              │  │
│  │  Bio text bodyMedium  max 3 lines            │  │
│  │  "Read more" if truncated → expand           │  │
│  │                                              │  │
│  │  8dp gap                                     │  │
│  │                                              │  │
│  │  [EN chip] or [BN chip] or [Both chip]       │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  16dp gap                                          │
│                                                    │
│  Stats Row (flex, equal 4 columns):                │
│  ┌──────┬──────┬──────────┬──────────┐            │
│  │ 42   │  7   │   183    │   94     │            │
│  │Poems │Storie│Followers │Following │            │
│  └──────┴──────┴──────────┴──────────┘            │
│  Number: titleMedium · Label: labelSmall tertiary  │
│  Followers/Following tappable → user list screen   │
│                                                    │
│  16dp gap                                          │
│                                                    │
│  Action buttons row:                               │
│  [Outlined "Edit Profile" flex:2]  [Icon Share]   │
│  36dp height each                                  │
│                                                    │
│  16dp gap                                          │
│                                                    │
│  SliverPersistentHeader (TabBar, pinned 48dp):     │
│  [Poems] [Stories] [Thoughts] [Liked]              │
│  A18 pill indicator animation                      │
│                                                    │
│  TabBarView:                                       │
│    Poems:    ListView PoemCard (var A)             │
│    Stories:  GridView 2-col story covers           │
│    Thoughts: ListView ThoughtCard                  │
│    Liked:    ListView PoemCard (var A)             │
│                                                    │
│  80dp bottom padding                               │
└────────────────────────────────────────────────────┘
```

---

## Screen 15 — Other User Profile (`/user/:username`)

```
Same layout as Screen 14 with these differences:

Cover photo: no edit pencil

Action buttons row:
  [FilledButton "Follow" flex:2] A07 animation
  OR [OutlinedButton "Following" flex:2]
  [IconButton message_outlined → /messages (create conversation)]
  [IconButton more_horiz_outlined → report/block sheet]

Stats Row: same 4-col layout

Tabs: Poems | Stories | Thoughts (no Liked tab)
Thoughts tab: visibility enforcement (public + mutual only)

Float banner (when viewing a poet you follow):
  None — clean

Back navigation: ← in AppBar (go_router pop)
```

---

## Screen 16 — Notifications (`/notifications`)

```
Background: BG-01

AppBar (56dp):
  Title: "Notifications" headlineSmall Playfair
  Trailing: "Mark all read" TextButton primary (only when unread > 0)

Content:
  ListView.builder
  Each item: Notification List Item (Section 3.8)
    72dp min height · 16dp padding
    Unread: surfaceVariant bg + 8dp primary dot left
    Read: surface bg

  Grouping by date:
    Date headers: "Today" / "Yesterday" / "3 days ago"
    labelMedium · tertiary · 16dp padding · 24dp top gap

  Tap item:
    Mark as read (optimistic)
    Navigate to relevant entity (poem/story/duel/profile)

  Swipe left:
    Dismissible — marks as read
    Red bg with check icon

  Empty state:
    Icon: notifications_none_outlined
    "The night is quiet. No one has knocked yet."

Entrance: A19 staggered items
New notification badge: A13 in feed AppBar
```

---

## Screen 17 — Story Creator (`/write/story`)

```
Background: BG-03

3-step flow with step indicator at top.

──────────────────────────────────────────────────────
STEP INDICATOR (always visible, pinned below AppBar):
  Row of 3 dots + connecting lines
  Active step: 24dp filled primary circle + labelSmall primary below
  Completed: 24dp primaryContainer circle + check icon 14dp primary
  Future: 24dp outlineVariant circle + labelSmall onSurfaceVariant
  Connector lines: 2dp, outlineVariant (completed stretch → primaryContainer)
──────────────────────────────────────────────────────

── Step 1: Cover & Identity ──────────────────────────

AppBar: ← back | "New Story" titleMedium | [Next →] FilledButton 40dp

Cover image picker (most prominent element):
  Full-width container, height 220dp
  Resting state:
    surfaceVariant bg, 12dp corner, dashed border 2dp outlineVariant
    Centred column:
      book_outlined icon 48dp, outlineVariant colour
      "Add your cover" titleSmall primary (16dp below icon)
      "First impressions matter." bodySmall onSurfaceVariant italic
  After image selected:
    CachedNetworkImage fills container, fit: BoxFit.cover, 12dp corner
    Bottom-right overlay: "Change" chip (inverseSurface 80%, 8dp corner, 8dp padding)

24dp gap

Story Title TextField (56dp, 8dp corner):
  Playfair Display 20sp, onSurface
  Placeholder: "Your story's first title…" (italic, onSurfaceVariant)
  Focused: 2dp primary border
  Character counter (right-aligned labelSmall tertiary): shown when > 60 chars

12dp gap

Description TextField (4 lines, 8dp corner):
  DM Sans 14sp, onSurface
  Placeholder: "A brief introduction that pulls a reader in…"
  Max 500 chars, character counter shown always (right-aligned, tertiary)

16dp gap

Genre row (horizontal scrollable chips, 32dp height, 4dp corner):
  Label: "Genre" labelMedium onSurfaceVariant (above row, 8dp gap)
  Chips: Fiction · Poetry Prose · Romance · Fantasy · Thriller · Literary ·
         Sci-Fi · Mystery · Historical · Horror · Self-Help · Other
  Selected chip: primaryContainer bg, primary text, 500 weight
  Unselected: surfaceVariant bg, outlineVariant border

12dp gap

Language selector (SegmentedButton, full-width, 40dp):
  [English] [বাংলা] [Both]

── Step 2: Mode & Collaboration ──────────────────────

AppBar: ← back | "Story Mode" titleMedium | [Next →]

Section: "How will your story unfold?"
  labelMedium onSurfaceVariant  (16dp top, 0 bottom)

Story Mode cards (two tall option cards, 8dp gap between):

  ┌────────────────────────────────────────────────────┐
  │  📖  Linear Story                                  │
  │  titleSmall onSurface                              │
  │                                                    │
  │  "Chapters follow one after another — readers     │
  │   move through your story in order, from          │
  │   Part 1 to the end."                             │
  │  bodySmall onSurfaceVariant                        │
  │                                                    │
  │  ──── Perfect for: novels, serials, memoirs ───── │
  │  labelSmall tertiary                               │
  └────────────────────────────────────────────────────┘

  ┌────────────────────────────────────────────────────┐
  │  🌿  Branching Story                               │
  │  titleSmall onSurface                              │
  │                                                    │
  │  "Chapters fork into different paths — readers    │
  │   make choices that shape the story. You write    │
  │   each branch."                                   │
  │  bodySmall onSurfaceVariant                        │
  │                                                    │
  │  ─── Perfect for: interactive fiction, CYOA ───── │
  │  labelSmall tertiary                               │
  └────────────────────────────────────────────────────┘

  Unselected card: surface bg, 12dp corner, 1dp outlineVariant border
  Selected card: primaryContainer bg tint, 12dp corner, 2dp primary border
    Radio button 20dp in top-right corner of each card

24dp gap

Section: "Who can write chapters?"
  labelMedium onSurfaceVariant

Collaboration Mode cards (two option cards, same visual pattern):

  ┌────────────────────────────────────────────────────┐
  │  ✍️  Just me                                       │
  │  "You are the sole author."                        │
  └────────────────────────────────────────────────────┘

  ┌────────────────────────────────────────────────────┐
  │  🤝  Open Collaboration                            │
  │  "Any reader can submit a chapter for your        │
  │   review and approval before it's published."     │
  └────────────────────────────────────────────────────┘

  ┌────────────────────────────────────────────────────┐
  │  🔒  Invite-Only                                   │
  │  "You invite specific writers to contribute."     │
  └────────────────────────────────────────────────────┘

── Step 3: Write First Chapter ───────────────────────

AppBar: ← back | "Part 1" titleMedium | [Publish] FilledButton primary

Part title field (40dp, underline-only border, Playfair 18sp):
  Placeholder: "This chapter is called…"

8dp gap

Poem body (Expanded TextField, same pattern as Poem Editor Screen 10):
  Placeholder: "Begin here…" italic onSurfaceVariant

Optional part cover:
  "Add cover for this part" TextButton + icon — at top of toolbar
  Tapping opens image picker; if selected, shows 80dp strip above title

Bottom toolbar (BottomAppBar, 56dp):
  [📷 Cover] [🏷 Tags] [😊 Mood] — icon buttons 48dp touch targets
  Right: word count labelSmall tertiary ("142 words")
```

---

## Screen 18 — Story Reader (`/story/:id`)

```
Background: BG-01

Scaffold(extendBodyBehindAppBar: true)

─────────────────────────────────────────────────
HERO COVER ZONE (top, 300dp total height):

  CachedNetworkImage full-bleed, BoxFit.cover, 300dp
  Blurhash placeholder while loading

  Gradient overlays (Stack):
    Top: LinearGradient transparent → black 35% (top 80dp)
         → keeps AppBar icons readable
    Bottom: LinearGradient transparent → surface 100% (bottom 100dp)
         → smooth blend into content below

  AppBar (transparent, elevation 0):
    Leading: ← back (white icon)
    Actions:
      [🔔 Follow / Following] OutlinedButton 32dp height, white border/text
                              → Filled primary when following
      [↗ share] IconButton white

─────────────────────────────────────────────────
CONTENT (SingleChildScrollView, no top padding — cover bleeds under AppBar):

  SliverToBoxAdapter starts at 250dp from top (so content overlaps bottom of cover):

  Meta chips row (horizontal scroll, 0 top padding):
    Genre chip (4dp, tertiaryContainer bg, onTertiaryContainer text)
    Language chip (4dp, same)
    storyMode chip:
      Linear:    "📖 Linear"    — tertiaryContainer bg
      Branching: "🌿 Branching" — secondaryContainer bg, secondary text
    If isCollab:
      collabMode chip:
        Open:        "🤝 Open Collab" — secondaryContainer
        Invite-only: "🔒 Invite-Only" — tertiaryContainer

  12dp gap

  "Story Title"
    headlineLarge Playfair, onSurface, max 3 lines

  8dp gap

  Author row:
    CircleAvatar 36dp
    Column: displayName titleSmall | @username + joinedDate bodySmall tertiary
    Spacer
    isVerifiedPoet → [✓ Verified Poet] chip, primaryContainer bg

  12dp gap

  Description:
    bodyMedium, onSurfaceVariant
    Max 3 lines + "Read more" TextButton primary inline
    Expand on tap with A04 animation (no page navigation)

  16dp gap

  Stats row (4 items, even spread):
    [📖 N Parts] [👁 N Reads] [👥 N Following] [🤍 N Likes]
    Each: Column(icon 20dp + labelSmall number + labelSmall tertiary label)

  If user is following:
    12dp gap
    "Your progress" labelMedium onSurface
    4dp gap
    LinearProgressIndicator (height 6dp, primary fill, tertiaryContainer bg)
    "Part 3 of 12" labelSmall tertiary right-aligned

  24dp gap
  Divider (outlineVariant)
  24dp gap

  ── CHAPTER LIST ──────────────────────────────────

  "Chapters" titleLarge onSurface
  8dp gap

  FOR LINEAR STORIES:
    ListView of ChapterListTile (not scrollable separately — inside outer scroll):
    Each tile (80dp min-height):
    ┌──────────────────────────────────────────────────────────┐
    │ [Part badge]  "Chapter Title"  titleSmall  ·  timestamp  │
    │  24dp circle  bodySmall  2 lines max         labelSmall  │
    │  primary bg   ─────────────────────────────  tertiary   │
    │               [✓ Read]  or  [→ Read now]                │
    └──────────────────────────────────────────────────────────┘
    Part badge: 24dp circle, primaryContainer bg, primary text labelMedium
    Read chapter: check icon 16dp + "Read" labelSmall tertiary
    Unread: "→ Read now" TextButton primary
    Current/next: highlighted row with primaryContainer bg tint 30%
    If collab contribution: small "🤝" icon 14dp next to chapter title

  FOR BRANCHING STORIES:
    Tree-style chapter navigator:
    Root part (Part 1) at top — same tile as above
    Branch children: indented 24dp, connected with 2dp outlineVariant vertical line
    Branch label chip: secondaryContainer bg, secondary text, labelSmall
      (e.g. "The dark path" / "The light path")
    Fork icon (call_split) 16dp primary at the branch point tile

  24dp gap (bottom safe area)

─────────────────────────────────────────────────
STICKY BOTTOM CTA:

  Positioned(bottom: 0):
  Container(
    padding: EdgeInsets.fromLTRB(16, 12, 16, 32),  // 32 = bottom safe area
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.outlineVariant)),
    )
  )
  FilledButton full-width 56dp:
    Not following / new:     "Start Reading" → Part 1
    Following, no progress:  "Start Reading" → Part 1
    In progress:             "Continue — Part 3" → last read part
    Completed:               "Read Again" → Part 1
```

---

## Screen 19 — Story Part Reader (`/story/:id/part/:partId`)

```
Background: BG-01

Scaffold(extendBodyBehindAppBar: true)

─────────────────────────────────────────────────
READING PROGRESS BAR (pinned very top, 4dp height):
  LinearProgressIndicator — sits above everything at very top of screen
  Fills as user scrolls through content (% of scroll position)
  Primary colour fill, transparent track (blends with status bar)

─────────────────────────────────────────────────
APPBAR (transparent, elevation 0):
  Leading: ← back (navigates to Story Reader /story/:id)
  Centre: Column(
    story title truncated — bodySmall tertiary max 1 line
    "Part N" — labelSmall onSurfaceVariant
  )
  Actions:
    [🔖 Save] IconButton
    [↗ Share] IconButton

─────────────────────────────────────────────────
OPTIONAL PART COVER (if part has coverImageUrl):
  Full-bleed 180dp image, BoxFit.cover
  Gradient scrim bottom transparent → surface 80%

─────────────────────────────────────────────────
CONTENT (SingleChildScrollView):
  Padding: EdgeInsets.fromLTRB(24, 88, 24, 160)
  (88dp top = AppBar height + extra; 160dp bottom = nav bar + safe area)

  Part badge row:
    "Part N" chip (4dp, primaryContainer bg, primary text, labelMedium)
    If collab contribution: "🤝 Contributed by @username" labelSmall tertiary

  12dp gap

  "Chapter Title"
    headlineLarge Playfair, onSurface

  12dp gap

  Author row:
    CircleAvatar 32dp + displayName titleSmall + date bodySmall tertiary

  16dp gap

  Mood chips (if mood set):
    Horizontal row, compact — same chip style as PoemCard

  24dp gap

  Chapter body text:
    language == 'en' → AppTypography.englishPoem (Playfair 18sp / 32sp lh)
    language == 'bn' → AppTypography.banglaPoem (system 18sp / 38sp lh)
    Full width, no max lines — reader scrolls freely

  48dp gap

─────────────────────────────────────────────────
BRANCH CHOICE SECTION (branching stories only, shown at end of content):
  If this part has child branches (parentPartId matches other parts' parentPartId):

  Divider + 24dp gap

  "Where does your story go?" titleMedium Playfair, centred
  "Choose your path." bodyMedium onSurfaceVariant italic, centred

  16dp gap

  Column of branch choice cards (one per child branch):
  ┌────────────────────────────────────────────────────────┐
  │  🌿  "The dark path"                titleSmall         │
  │      First line of that chapter...  bodySmall variant  │
  │                               [Read this path →]       │
  └────────────────────────────────────────────────────────┘
  Card: surface bg, 12dp corner, 1dp outlineVariant border
  On tap: A21 slide-right transition → navigate to child part
  Selected/previously read: primaryContainer bg tint, primary border

─────────────────────────────────────────────────
STICKY BOTTOM NAVIGATION BAR:

  Positioned(bottom: 0):
  Container(
    height: 64dp + bottomSafeArea,
    color: AppColors.surface,
    border: Border(top: BorderSide(AppColors.outlineVariant)),
    child: Row [
      // Previous
      if (hasPrev)
        Expanded(child: TextButton.icon(
          icon: Icon(Icons.arrow_back_ios, size: 16),
          label: Text("Part ${partNumber - 1}"),
        ))
      else
        Expanded(child: SizedBox())  // empty slot to maintain layout

      // Engagement
      Row(mainAxisSize: MainAxisSize.min, children: [
        _LikeButton(count: part.likesCount),   // 48dp touch target
        SizedBox(width: 4),
        _CommentButton(count: part.commentsCount),
        SizedBox(width: 4),
        _SaveButton(),
      ])

      // Next (linear) or disabled at end
      if (hasNext && !isBranching)
        Expanded(child: TextButton.icon(
          icon: Text("Part ${partNumber + 1}"),
          label: Icon(Icons.arrow_forward_ios, size: 16),
          iconAlignment: IconAlignment.end,
        ))
      else if (isBranching && hasBranches)
        Expanded(child: TextButton("Choose path ↓",
          // scrolls down to branch section
        ))
      else
        Expanded(child: SizedBox())
    ]
  )
  A21 slide animation on Prev/Next tap
```

---

## Screen 20 — Collaborative Poem (`/collab/:id`)

```
Background: BG-01

AppBar:
  ← back
  "Collaborative Poem" titleMedium
  [Live pill A12 — if Pusher channel has active writers]
  [🔗 Invite] trailing — only shown if collabType is "invite-only" and user is originator

Hero area (16dp padding):
  "Poem Title" headlineLarge Playfair
  Contributor avatars: 3 overlapping 32dp circles + "+N" badge labelSmall
  Row:
    Status badge: "Open to stanzas" (secondaryContainer) or "Closed" (tertiaryContainer)
    collabType badge: "🌐 Open" or "🔒 Invite-Only" — tertiaryContainer, labelSmall

  > ⚠️ Collaborative poems are ALWAYS linear — stanzas chain in sequential order.
  > There is no branching mode. Do NOT add a branching indicator here.

24dp gap

Stanza chain (ListView, not independently scrollable):
  Each stanza block:
    Left border: 3dp, author's assigned accent colour (cycle through mood palette per contributor)
    Content: bodyLarge Playfair (EN) / system (BN)
    Author credit: Row [CircleAvatar 24dp]  displayName labelSmall tertiary  right-aligned
    Bottom margin: 16dp

  Live arrivals (Pusher stanza_added event):
    New stanza slides in from bottom — A04 slide-down animation 300ms
    Brief primary left-border pulse (A12) for 2 seconds then settles to author colour

Add stanza section (if status is open):
  24dp gap
  Dashed border card (2dp outlineVariant dashed, 12dp corner, 16dp padding):
    "Add a stanza +" labelLarge primary
    Tap: expands to full TextField (A04-like slide-down, 300ms)
      TextField: Playfair EN / system BN, min 3 lines
      Char guide: "A stanza is typically 4–8 lines" labelSmall tertiary
      Row: [Cancel TextButton] [Spacer] ["Add my line" FilledButton]

  If collabType is "invite-only" and user is NOT a contributor:
    Show locked state instead:
    Lock icon 32dp outlineVariant + "This poem is invite-only." bodyMedium centred
```

---

## Screen 21 — Duel Screen (`/duel/:id`)

```
Background: BG-01

AppBar:
  ← back
  "⚔ Duel"  titleMedium secondary
  Theme: subtitle "Theme: Autumn Longing" labelSmall tertiary
  Timer chip right: [🕐 23h left] errorContainer bg

Content (scrollable, 24dp padding):

  Two-column layout (equal width, 8dp gap):
  ┌──────────────┐  ┌──────────────┐
  │  [◉ 48dp]    │  │  [◉ 48dp]    │
  │  Poet A name │  │  Poet B name │
  │              │  │              │
  │  Full poem   │  │  Full poem   │
  │  content     │  │  content     │
  │  scrollable  │  │  scrollable  │
  │  within col  │  │  within col  │
  │              │  │              │
  │  N votes     │  │  N votes     │
  └──────────────┘  └──────────────┘

  Each column: surfaceVariant bg, 12dp corner, 12dp padding
  Scroll: both columns scroll independently

  32dp gap

  Vote section:
    "Cast your vote" titleMedium centred
    Row of two OutlinedButtons 48dp height, equal flex:
      [Vote for Poet A]  [Vote for Poet B]
      On vote: button selected fills primary, other stays outlined
               A11 progress bars animate below

  Progress bars (after any vote):
    Two labeled bars: challenger (primary) / challengee (secondary)
    A11 animation

  Your vote: "You voted for Poet A" bodyMedium success colour centred
```

---

## Screen 22 — Video Feed (`/video-feed`)

```
Background: BG-04 (pure black + gradient overlays per item)

SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
on enter, restore on exit

PageView.builder vertical (A08 snap physics):

Per video item — full screen Stack:

  1. VideoPlayer (fill entire screen, BoxFit.cover)
     auto-plays when active, pauses when not

  2. Top gradient h:160 (from black 50% → transparent)

  3. Bottom gradient h:260 (from black 75% → transparent)

  4. SafeArea top bar:
     ← Back  48dp  white   ←16dp margin
     "For You · Following" toggle centred (A: crossfade 150ms)

  5. Right action column (Positioned right:12, bottom:120):
     [◉ 48dp avatar + ➕ follow badge if unfollowed]
     24dp gap
     [❤ count]  28dp white icon + labelSmall white
     [💬 count] 28dp
     [🔖]       28dp
     [↗]        28dp
     Each: 48dp touch target, A02-style like animation

  6. Bottom info (Positioned left:16, right:88, bottom:88):
     @displayName  titleMedium white
     "Poem Title"  headlineSmall Playfair white
     Two-line snippet  bodyMedium rgba(255,255,255,0.8)
     [Mood chip] secondaryContainer bg 70% opacity

  7. GestureDetector full screen:
     Tap: play/pause
     → White 48dp circle flashes centre, 400ms fadeOut

  A08 parallax on bottom info during page swipe

Empty state: black bg, A20-style entrance
  "No recitations yet. Your voice could be the first."
  [FilledButton "Record a poem"] — navigates to poem editor with video mode
```

---

## Screen 23 — Messages List (`/messages`)

```
Background: BG-01

AppBar 56dp:
  "Messages" headlineSmall Playfair
  Trailing: edit_outlined icon → new conversation sheet

Search bar below AppBar (not pinned, scrolls away):
  56dp, surfaceVariant bg, "Search conversations…"

ListView.builder:
  Each item: Conversation List Item (Section 3.9)
    Height 72dp min
    Tap: navigate to thread with A06 transition
    Swipe left: Dismissible (red bg, archive icon)

Empty state:
  Icon: chat_bubble_outline_outlined
  "No conversations yet. Send your first word."
  [FilledButton "Start a conversation"]

New conversation sheet (A04):
  Search field for user lookup
  Results: ListView of compact UserCards with "Message" button
```

---

## Screen 24 — Message Thread (`/messages/:conversationId`)

```
Background: SurfaceVariant (#EDF4F0)

AppBar 56dp:
  ← back
  [◉ 40dp avatar] displayName titleMedium
  Trailing: call_outlined (future) + more_horiz

Content:
  ListView.builder (reverse: true — newest at bottom)
  Padding: 16dp horizontal, 8dp vertical per bubble

  Timestamp dividers: centred, labelSmall tertiary
    Only when gap > 30 min between messages

  Own bubble: Section 3.10 (right-aligned, primary bg)
  Other bubble: Section 3.10 (left-aligned, surface bg)
  Poem/story share card: Section 3.10
  New message: A24 animation

  Typing indicator (when typing: true):
    Other user's avatar + 3-dot bounce animation
    Dots: 6dp circles, onSurfaceVariant
    Bounce: each dot offset 100ms, translateY -4dp and back, 600ms loop
    Fades out after 3s of no typing event

Input bar (sticky bottom):
┌──────────────────────────────────────────────────────┐
│  [◉ 32dp]  [TextField flex:1, 8dp corner]  [📎] [➤] │
│  56dp height, surface bg, outlineVariant top 1dp     │
└──────────────────────────────────────────────────────┘
  Send button: 40dp circle Primary, paper-plane icon
               A24 rotation animation on send
  Attachment: open file picker for poem share
  TextField: "Say something…" placeholder, multiline (max 4 lines before scroll)
```

---

## Screen 25 — Drafts (`/write/drafts`)

```
Background: BG-01

AppBar: "Drafts" headlineSmall Playfair

Content: ListView of draft items
  Each: 72dp height min
    Title (or "Untitled poem" italic if empty) titleSmall
    Preview (first line or "No content yet") bodySmall variant
    Timestamp labelSmall tertiary right

  Swipe left: delete draft (red bg, delete icon, Dismissible)
  Tap: opens poem editor pre-filled with draft

Empty:
  Icon: description_outlined
  "Your drafts are waiting. Pick up where you left off."
```

---

# PART 5 — FULL FLUTTER THEME IMPLEMENTATION

```dart
// lib/core/theme/app_theme.dart
ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:              AppColors.primary,
    onPrimary:            AppColors.onPrimary,
    primaryContainer:     AppColors.primaryContainer,
    onPrimaryContainer:   AppColors.onPrimaryContainer,
    secondary:            AppColors.secondary,
    onSecondary:          AppColors.onSecondary,
    secondaryContainer:   AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary:             AppColors.tertiary,
    onTertiary:           AppColors.onTertiary,
    tertiaryContainer:    AppColors.tertiaryContainer,
    onTertiaryContainer:  AppColors.onTertiaryContainer,
    surface:              AppColors.surface,
    onSurface:            AppColors.onSurface,
    // surfaceVariant deprecated in Flutter 3.18 → surfaceContainerHighest
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant:     AppColors.onSurfaceVariant,
    outline:              AppColors.outline,
    outlineVariant:       AppColors.outlineVariant,
    error:                AppColors.error,
    errorContainer:       AppColors.errorContainer,
    inverseSurface:       AppColors.inverseSurface,
    onInverseSurface:     AppColors.inverseOnSurface,
    // background & onBackground removed — deprecated since Flutter 3.18
    // scaffoldBackgroundColor below handles the background color
    shadow:               Colors.transparent,
    scrim:                Color(0x52000000),
  ),
  textTheme: AppTypography.textTheme,
  scaffoldBackgroundColor: AppColors.background,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.dmSans(
      fontSize: 16, fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
  ),

  cardTheme: const CardTheme(
    color: AppColors.surface,
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: GoogleFonts.dmSans(
      fontSize: 14, color: AppColors.onSurfaceVariant,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.secondaryContainer,
    disabledColor: AppColors.tertiaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400),
    side: BorderSide.none,
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      elevation: 0,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      minimumSize: const Size(64, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 3,
    shape: CircleBorder(),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryContainer,
    height: 80,
    elevation: 0,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    labelTextStyle: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
        ? GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)
        : GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.outline),
    ),
    iconTheme: WidgetStateProperty.resolveWith((states) =>
      IconThemeData(
        color: states.contains(WidgetState.selected)
          ? AppColors.primary : AppColors.outline,
        size: 24,
      ),
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    // Note: modalBackgroundColor was removed in Flutter 3.27+ — backgroundColor covers both.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    showDragHandle: false,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.inverseSurface,
    contentTextStyle: GoogleFonts.dmSans(
      fontSize: 14, color: AppColors.inverseOnSurface,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    behavior: SnackBarBehavior.floating,
  ),

  dividerTheme: const DividerThemeData(
    color: AppColors.outlineVariant,
    thickness: 1,
    space: 0,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.tertiaryContainer,
    linearMinHeight: 6,
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? AppColors.onPrimary : AppColors.outline),
    trackColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? AppColors.primary : AppColors.tertiaryContainer),
  ),

  tabBarTheme: TabBarTheme(
    indicator: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14),
    unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w400, fontSize: 14),
  ),
);
```

---

---

# PART 6 — PRODUCTION AI CODING PROMPT

**How to use:** Paste the block below verbatim at the start of every AI coding session.
Follow it with the specific Part 4 screen section and any Part 3 components you need.
Do not feed the entire design.md at once — feed only what is needed for the current task.

**Recommended session structure:**
```
1. Paste Part 6 prompt (below)
2. Paste Part 1 foundations (colours, typography, spacing)
3. Paste the specific Screen XX section from Part 4
4. Paste relevant Component sections from Part 3
5. Paste the Animation entries from Part 2 referenced in the screen
6. State: "Implement [Screen Name] exactly as specified above."
```

---

```
You are implementing the Verso Flutter Android app.
Verso is a literary social platform — a sanctuary for poets and readers.
Design identity: "Sage & Vellum" — cream pages, sage-teal ink, generous whitespace.

The design.md sections I have shared with you are your ONLY authoritative specification.
Every measurement, colour token, animation ID, and layout value is defined there.
If something is not specified, ask before deciding — never invent values.

══════════════════════════════════════════════════════════════════
HARD RULES — VIOLATIONS WILL BE REJECTED IN CODE REVIEW
══════════════════════════════════════════════════════════════════

── COLOURS ──────────────────────────────────────────────────────
  ✗  NEVER: Color(0xFF...) · Colors.green · Color.fromRGBO(...)
  ✓  ALWAYS: AppColors.primary · AppColors.surface · AppColors.moodRomantic
  ✓  EXCEPTION: Colors.transparent · Colors.black in video overlay gradients ONLY

  Quick reference:
    Primary action bg    → AppColors.primary
    Card / screen bg     → AppColors.surface
    Input field bg       → AppColors.surfaceVariant
    Body text            → AppColors.onSurface
    Caption / timestamp  → AppColors.onSurfaceVariant (Tertiary family)
    Active border        → AppColors.primary (2dp)
    Inactive border      → AppColors.outline (1dp)
    Subtle separator     → AppColors.outlineVariant (1dp)
    Mood left border     → AppColors.mood(moodName).withValues(alpha: 0.8) (3dp)

── TYPOGRAPHY ───────────────────────────────────────────────────
  ✗  NEVER: fontSize: 16 · fontFamily: 'Playfair' · fontWeight: FontWeight.w600
  ✓  ALWAYS: Theme.of(context).textTheme.bodyLarge
             AppTypography.englishPoem · AppTypography.poemBody(language)

  Quick reference:
    Poem titles (EN)         → textTheme.headlineLarge (Playfair 32sp)
    Screen / section titles  → textTheme.headlineSmall (Playfair 24sp)
    Card title               → textTheme.titleSmall (DM Sans 14sp w500)
    Body copy / descriptions → textTheme.bodyLarge (DM Sans 16sp)
    Chips, tabs, badges      → textTheme.labelMedium (DM Sans 12sp)
    Timestamps, captions     → textTheme.labelSmall (DM Sans 11sp)
    English poem body        → AppTypography.englishPoem (Playfair 18sp, 0.3 tracking)
    Bengali poem body        → AppTypography.banglaPoem (system font, NO fontFamily set)

  ⚠️  BANGLA RULE: Never set fontFamily on any Bengali text, not even to "system".
      Simply omit fontFamily entirely. Android resolves it to Noto Serif Bengali.

── SPACING ──────────────────────────────────────────────────────
  ✗  NEVER: SizedBox(height: 13) · padding: EdgeInsets.all(7)
  ✓  ALWAYS: multiples of 4dp — use 4, 8, 12, 16, 24, 32, 48 only

  Quick reference:
    Icon internal padding    → 4dp
    Chip padding / icon gap  → 8dp
    Card tight internal      → 12dp
    Standard margin / pad    → 16dp
    Between content sections → 24dp
    Hero spacing             → 32dp
    Screen safe padding      → 48dp

── SHAPES ───────────────────────────────────────────────────────
  ✗  NEVER: BorderRadius.circular(10) or any unlisted radius value
  ✓  ALWAYS: AppShapes.xs (4dp) · sm (8dp) · md (12dp) · lg (16dp) · xl (28dp)
             AppShapes.full (circle) · AppShapes.sheet (top 16dp only)

  Quick reference:
    Chips, tags, snackbars   → AppShapes.xs (4dp)
    Inputs, search, buttons  → AppShapes.sm (8dp)
    PoemCard / ThoughtCard   → AppShapes.md (12dp)
    Bottom sheets / modals   → AppShapes.lg (16dp) or AppShapes.sheet
    FAB write button         → AppShapes.xl (28dp)
    Avatars, icon circles    → AppShapes.full

── ANIMATIONS ───────────────────────────────────────────────────
  ✗  NEVER: add any animation not defined in Part 2 (A01–A30)
  ✗  NEVER: Duration(milliseconds: 320) or any unlisted duration
  ✓  ALWAYS: AppDurations.quick (150ms) · standard (250ms) · emphasized (350ms)
  ✓  ALWAYS: AppCurves.emphasized · sheetOpen · standard · spring

  ⚠️  REDUCED MOTION — every animation must have this fallback:
      if (MediaQuery.of(context).disableAnimations) {
        // Replace full animation with simple 150ms fade only:
        widget.animate().fadeIn(duration: AppDurations.quick)
      }

── LISTS ────────────────────────────────────────────────────────
  ✗  NEVER: Column(children: items.map((i) => Widget(i)).toList())
  ✓  ALWAYS: ListView.builder() or SliverList.builder() for > 3 items

── IMAGES ───────────────────────────────────────────────────────
  ✗  NEVER: Image.network(url)
  ✓  ALWAYS: CachedNetworkImage(imageUrl: url, placeholder: blurhash widget)

── NAVIGATION ───────────────────────────────────────────────────
  ✗  NEVER: Navigator.push() · Navigator.pushNamed()
  ✓  ALWAYS: context.go('/route') or context.push('/route') from go_router

── STATE MANAGEMENT ─────────────────────────────────────────────
  ✗  NEVER: setState() for data that comes from the server
  ✓  ALWAYS: Riverpod providers (AsyncNotifierProvider, StreamProvider, etc.)
  ✓  setState() is acceptable ONLY for purely local UI state (e.g. toggle visibility)

── FIREBASE ─────────────────────────────────────────────────────
  ✗  NEVER: Firebase Auth · Firestore · Realtime Database
  ✓  firebase_messaging is used ONLY to read the FCM device token — nothing else

── ACCESSIBILITY ────────────────────────────────────────────────
  ✓  Every tappable element: minimum 48×48dp touch target (use GestureDetector
     or InkWell with a SizedBox(width:48, height:48) if needed)
  ✓  Every interactive element: Semantics(label: '...', button: true) wrapper
  ✓  Poem body text: never set maxFontSizeMultiplier — let the OS scale freely
  ✓  Screen reader order: match the visual top-to-bottom, left-to-right flow

── COPY & STRINGS ───────────────────────────────────────────────
  ✗  NEVER: "Loading..." · "No results" · "Error" · "Success" · "Done"
  ✓  ALWAYS: Use the exact poetic strings from knowledge.md for the current screen
  ✓  If a string is not in knowledge.md, write something evocative that fits the
     literary tone — never generic, never transactional

══════════════════════════════════════════════════════════════════
IMPLEMENTATION CHECKLIST — COMPLETE IN THIS EXACT ORDER
══════════════════════════════════════════════════════════════════

Before writing any code, confirm you have read:
  □ The Part 4 screen spec for this screen
  □ Every Part 3 component referenced in the screen spec
  □ Every Part 2 animation referenced (Axx IDs)
  □ The background type (BG-XX) from Section 1.7

Build in this order:
  □ Step 1 — Scaffold with correct backgroundColor (BG-XX)
  □ Step 2 — Background decoration layers (Stack if BG-02/04)
  □ Step 3 — AppBar (only if screen spec includes one)
  □ Step 4 — SafeArea and main content layout (top → bottom)
  □ Step 5 — Populate content with real components from Part 3
  □ Step 6 — Bottom NavigationBar or sticky input bar (if present)
  □ Step 7 — All onTap / onLongPress / gesture handlers
  □ Step 8 — Navigation calls (context.go / context.push)
  □ Step 9 — Loading states (Variant C skeleton from each component)
  □ Step 10 — Empty states (poetic copy from knowledge.md)
  □ Step 11 — Error states (snackbar with poetic copy, not a full-screen error)
  □ Step 12 — Animations (after layout is visually correct — never before)
  □ Step 13 — Semantics wrappers on all interactive elements
  □ Step 14 — reducedMotion fallback for every animation
  □ Step 15 — Final check: no hardcoded colours, fonts, sizes, or durations

After implementation, run this self-audit:
  □ grep for Color(0xFF → should be 0 results in widget files
  □ grep for Navigator.push → should be 0 results
  □ grep for Image.network → should be 0 results
  □ grep for fontSize: → should be 0 results in widget files
  □ grep for Column(children: items.map → should be 0 results

══════════════════════════════════════════════════════════════════
DESIGN IDENTITY REMINDER
══════════════════════════════════════════════════════════════════

App name:        Verso
Design language: "Sage & Vellum"
Feeling:         A beautiful literary journal — cream pages, sage ink, generous margins
Primary colour:  Deep sage-teal  → AppColors.primary  (#1F6B5A)
Background:      Vellum white    → AppColors.surface   (#F6FAF8)
Type heroes:     Playfair Display (all poetry and literary titles)
                 DM Sans (all UI chrome — buttons, labels, metadata)
                 System default (Bengali text — no fontFamily, ever)
Motion:          Every animation communicates a state change. Nothing is decorative.
Copy:            Every string is poetic. If it sounds like a SaaS app, rewrite it.
Shadows:         None — tonal elevation only. Exception: video feed overlays.
Mood borders:    3dp left border on PoemCard, 80% opacity, mood colour only.
                 NEVER use mood colours as card backgrounds or fill colours.
```

