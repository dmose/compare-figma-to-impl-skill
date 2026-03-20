# Comparison Checklist & Reusable Patterns

## Full Property Checklist

### Layout Properties
- `display`
- `flex-direction`
- `align-items`
- `justify-content`
- `gap`
- `position`

### Box Model
- `width`, `height` (computed + `getBoundingClientRect()`)
- `padding` (all sides)
- `margin` (all sides)
- `border` (width, style, color)
- `border-radius`
- `box-sizing`

### Background
- `background-image` (gradients, urls)
- `background-color`
- `background-position`
- `background-size`
- `background-repeat`

### Typography
- `font-family`
- `font-size`
- `font-weight`
- `line-height`
- `color`
- `text-overflow`
- `white-space`
- `overflow`
- `letter-spacing`

### Effects
- `box-shadow`
- `opacity`
- `outline`

### Icon/Image

**IMPORTANT**: Icons may be rendered as `<img src="...">` elements, as
`<div>`s with `background-image`, as inline `<svg>`, or via
`list-style-image`. Always dump `outerHTML` first to determine the
rendering technique before extracting properties.

- `outerHTML` (truncated — reveals the actual element type)
- `src` attribute (for `<img>` elements — this is the icon identity)
- `alt` attribute
- `fill` (for SVG via `-moz-context-properties`)
- `stroke`
- `-moz-context-properties`
- `list-style-image`
- `background-image` (for CSS-based icons)
- `opacity`
- image `width` / `height` (via `getBoundingClientRect()`)

## Reusable Chrome Script: Extract Computed Styles

This script extracts all comparison-relevant computed styles from an
element. Adapt the selector path for the target component.

```js
(function() {
  const browser = gBrowser.selectedBrowser;
  const contentDoc = browser.contentDocument;
  const win = contentDoc.defaultView;

  // -- Adapt this section to target the element --
  const aiWindow = contentDoc.querySelector('ai-window');
  const shadow = aiWindow.shadowRoot;
  const el = shadow.querySelector('.target-element');
  // -- End adaptation --

  function getStyles(el) {
    const cs = win.getComputedStyle(el);
    return {
      display: cs.display,
      flexDirection: cs.flexDirection,
      alignItems: cs.alignItems,
      justifyContent: cs.justifyContent,
      gap: cs.gap,
      width: cs.width,
      height: cs.height,
      padding: cs.padding,
      margin: cs.margin,
      border: cs.border,
      borderRadius: cs.borderRadius,
      background: cs.background.substring(0, 300),
      backgroundColor: cs.backgroundColor,
      backgroundImage: cs.backgroundImage.substring(0, 300),
      backgroundPosition: cs.backgroundPosition,
      backgroundSize: cs.backgroundSize,
      fontSize: cs.fontSize,
      fontWeight: cs.fontWeight,
      fontFamily: cs.fontFamily,
      lineHeight: cs.lineHeight,
      color: cs.color,
      boxShadow: cs.boxShadow,
      opacity: cs.opacity,
      overflow: cs.overflow,
      textOverflow: cs.textOverflow,
      whiteSpace: cs.whiteSpace,
    };
  }

  function getRect(el) {
    const r = el.getBoundingClientRect();
    return {
      x: Math.round(r.x * 10) / 10,
      y: Math.round(r.y * 10) / 10,
      w: Math.round(r.width * 10) / 10,
      h: Math.round(r.height * 10) / 10,
    };
  }

  return {
    styles: getStyles(el),
    rect: getRect(el),
  };
})()
```

## Reusable Chrome Script: Extract Icon/Image Attributes

This script extracts both HTML attributes and computed styles for
icon/image elements. It handles the common case where the icon element
IS the `<img>` tag (not a container with a child `<img>`).

```js
(function() {
  const browser = gBrowser.selectedBrowser;
  const contentDoc = browser.contentDocument;
  const win = contentDoc.defaultView;

  // -- Adapt this section to find the icon elements --
  const aiWindow = contentDoc.querySelector('ai-window');
  const shadow = aiWindow.shadowRoot;
  const icons = shadow.querySelectorAll('.urlbarView-favicon');
  // -- End adaptation --

  function getIconInfo(el) {
    const cs = win.getComputedStyle(el);
    const rect = el.getBoundingClientRect();
    return {
      tag: el.tagName.toLowerCase(),
      outerHTML: el.outerHTML.substring(0, 400),
      src: el.getAttribute('src') || '',
      alt: el.getAttribute('alt') || '',
      backgroundImage: cs.backgroundImage,
      listStyleImage: cs.listStyleImage,
      mozContextProperties: cs.getPropertyValue('-moz-context-properties'),
      fill: cs.fill,
      opacity: cs.opacity,
      width: rect.width,
      height: rect.height,
    };
  }

  const result = [];
  icons.forEach((icon, i) => {
    result.push({ index: i, ...getIconInfo(icon) });
  });
  return result;
})()
```

## Reusable Chrome Script: Check Pseudo-Elements

```js
(function() {
  const browser = gBrowser.selectedBrowser;
  const contentDoc = browser.contentDocument;
  const win = contentDoc.defaultView;

  // -- Adapt selector --
  const el = /* ... */;
  // -- End --

  function getPseudo(el, pseudo) {
    const cs = win.getComputedStyle(el, pseudo);
    return {
      content: cs.content,
      display: cs.display,
      width: cs.width,
      height: cs.height,
      background: cs.background.substring(0, 200),
      position: cs.position,
      borderLeft: cs.borderLeft,
    };
  }

  return {
    before: getPseudo(el, '::before'),
    after: getPseudo(el, '::after'),
  };
})()
```

## Reusable Chrome Script: Check CSS Variable Resolution

```js
(function() {
  const browser = gBrowser.selectedBrowser;
  const contentDoc = browser.contentDocument;
  const win = contentDoc.defaultView;

  // -- Adapt selector --
  const el = /* ... */;
  // -- End --

  const varNames = [
    '--space-xsmall', '--space-small', '--space-medium', '--space-large',
    '--font-size-root', '--font-size-small', '--font-size-large',
    '--font-weight', '--font-weight-semibold', '--font-weight-bold',
    '--button-font-size', '--button-font-weight', '--button-padding',
    '--button-min-height', '--button-border-radius',
    '--border-width', '--border-radius-circle',
    '--size-item-small', '--size-item-medium', '--size-item-large',
  ];

  const cs = win.getComputedStyle(el);
  const resolved = {};
  for (const v of varNames) {
    const val = cs.getPropertyValue(v).trim();
    if (val) resolved[v] = val;
  }
  return resolved;
})()
```

## Firefox Design Token Reference (Quick)

### Spacing
| Token | Value |
|-------|-------|
| `--space-xxsmall` | 0.125rem (2px) |
| `--space-xsmall` | 0.25rem (4px) |
| `--space-small` | 0.5rem (8px) |
| `--space-medium` | 0.75rem (12px) |
| `--space-large` | 1rem (16px) |
| `--space-xlarge` | 1.5rem (24px) |
| `--space-xxlarge` | 2rem (32px) |

### Font Size
| Token | Value |
|-------|-------|
| `--font-size-root` | 15px |
| `--font-size-xsmall` | 0.733rem (11px) |
| `--font-size-small` | 0.867rem (13px) |
| `--font-size-large` | 1.133rem (17px) |
| `--font-size-xlarge` | 1.467rem (22px) |
| `--font-size-xxlarge` | 1.6rem (24px) |

### Font Weight
| Token | Value |
|-------|-------|
| `--font-weight` | normal (400) |
| `--font-weight-semibold` | 600 |
| `--font-weight-bold` | 700 |

### Sizes
| Token | Value |
|-------|-------|
| `--size-item-small` | 16px |
| `--size-item-medium` | 24px |
| `--size-item-large` | 32px |

### Border
| Token | Value |
|-------|-------|
| `--border-width` | 1px |
| `--border-radius-small` | 4px |
| `--border-radius-medium` | 8px |
| `--border-radius-circle` | 9999px |

## Common Gotchas

### `background-image: none` when variable is set
If `getComputedStyle` shows `background-image: none` but
`background-position` and `background-size` have non-default values,
the CSS rules are matching but the image value is invalid. Check:
1. Does the CSS variable contain a `url()` wrapper?
2. A bare URL string like `chrome://foo/bar.svg` is NOT valid for
   `background-image` — it must be `url(chrome://foo/bar.svg)`.

### Shadow DOM and `::part()` styling
`::part()` only pierces ONE shadow boundary. To style an element
two levels deep, the inner shadow must re-export the part via
`exportparts` or the intermediate host must expose its own part.

### Figma gradient angles vs CSS
Figma uses the same angle convention as CSS (0deg = bottom-to-top,
90deg = left-to-right, clockwise). Angles are directly comparable.
However, Figma's generated code may produce different stop positions
than the implementation — always check visual equivalence, not just
numerical equality.
