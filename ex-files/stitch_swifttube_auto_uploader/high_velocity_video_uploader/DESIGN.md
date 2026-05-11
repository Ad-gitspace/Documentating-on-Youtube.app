---
name: High-Velocity Video Uploader
colors:
  surface: '#17130a'
  surface-dim: '#17130a'
  surface-bright: '#3e382e'
  surface-container-lowest: '#120e06'
  surface-container-low: '#201b12'
  surface-container: '#241f16'
  surface-container-high: '#2f2920'
  surface-container-highest: '#3a342a'
  on-surface: '#ece1d2'
  on-surface-variant: '#d3c5ad'
  inverse-surface: '#ece1d2'
  inverse-on-surface: '#353026'
  outline: '#9c8f7a'
  outline-variant: '#4f4534'
  surface-tint: '#f9bd34'
  primary: '#f9bd34'
  on-primary: '#402d00'
  primary-container: '#d19a03'
  on-primary-container: '#4c3600'
  inverse-primary: '#7a5900'
  secondary: '#afd27a'
  on-secondary: '#213600'
  secondary-container: '#334f02'
  on-secondary-container: '#9ec06a'
  tertiary: '#95ccff'
  on-tertiary: '#003352'
  tertiary-container: '#55aaed'
  on-tertiary-container: '#003d60'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdea3'
  primary-fixed-dim: '#f9bd34'
  on-primary-fixed: '#261900'
  on-primary-fixed-variant: '#5d4200'
  secondary-fixed: '#caef93'
  secondary-fixed-dim: '#afd27a'
  on-secondary-fixed: '#121f00'
  on-secondary-fixed-variant: '#334f02'
  tertiary-fixed: '#cde5ff'
  tertiary-fixed-dim: '#95ccff'
  on-tertiary-fixed: '#001d32'
  on-tertiary-fixed-variant: '#004a75'
  background: '#17130a'
  on-background: '#ece1d2'
  surface-variant: '#3a342a'
typography:
  headline-lg:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.05em
  button-text:
    fontFamily: Sora
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1'
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-padding: 20px
---

## Brand & Style
The design system is engineered for high-performance content creators. The brand personality is aggressive, precise, and automated, mirroring the speed of fiber-optic uploads and professional broadcast workflows. While maintaining its high-velocity roots, the aesthetic has shifted toward a **Technical Amber Precision**—a fusion of High-Contrast Bold elements and Glassmorphism.

The goal is to make the complex process of video transcoding, metadata tagging, and publishing feel like a seamless, one-tap operation. Visual weight is concentrated on warm, "High-Energy" focal points, while secondary controls recede into a sophisticated dark-mode environment that emphasizes status and reliability.

## Colors
The palette is built on a "Tactical Terminal" concept. The primary **Industrial Gold** (#d19a03) is used for critical actions and active states, providing a high-visibility signal that is authoritative and precise. The background is a deep, neutral-toned dark mode that allows video thumbnails and white typography to pop.

- **Primary:** Industrial Gold for "Publish," "Upload," and active processing states.
- **Secondary:** Tactical Olive (#6f8f3f) for secondary actions, confirmation states, and grouping.
- **Tertiary:** Sky Blue (#68bbff) is reserved for specialized data visualizations, such as bitrate graphs or network speed indicators.
- **Glass:** Translucent white overlays (5-10% opacity) create technical panels that float over the deep background.

## Typography
This design system uses **Sora** for headlines to provide a geometric, technical edge that feels modern and industrial. **Inter** is used for body copy and metadata to ensure maximum legibility during fast-paced interactions. 

Key technical data (file sizes, bitrates, upload percentages) should use **Sora** with slightly tighter letter spacing to emphasize the "machine-processed" aesthetic. Use uppercase labels for secondary information to create a hierarchical distinction from primary content.

## Layout & Spacing
The layout follows a **fluid grid** model optimized for thumb-reachability. We use an 8px rhythmic scale. 

- **Safe Zones:** 20px horizontal margins ensure content does not hit the edge of the glass panels.
- **Vertical Stack:** Elements are grouped into "Technical Containers" with 12px internal padding and 16px external gutters.
- **Automation View:** For data-heavy screens (upload queues), spacing is compressed to 8px gutters to allow more items to be visible simultaneously.

## Elevation & Depth
Depth is achieved through **Glassmorphism** rather than traditional drop shadows.
- **Level 1 (Base):** Deep neutral surface.
- **Level 2 (Panels):** Translucent glass (5% white) with a 1px stroke (15% white) to define the edge.
- **Level 3 (Modals/Overlays):** Backdrop blur (20px) with 10% white fill. This creates a "frosted" effect that keeps the focus on the foreground while maintaining the sense of the high-energy environment behind it.
- **Level 4 (Primary Actions):** Industrial Gold surfaces with a subtle outer glow (#d19a03 at 30% opacity) to simulate light emission.

## Shapes
The design system utilizes a **Pill-shaped (3)** roundedness strategy. While the brand is technical, the highly rounded corners provide a "pro-tool" ergonomic feel that reduces visual fatigue.
- **Buttons and Navigation:** Use a generous 1rem (DEFAULT) rounded radius.
- **Cards and Containers:** Use 2rem (rounded-lg) to 3rem (rounded-xl) radii for a distinct, modern silhouette. 
- **Media Thumbnails:** Use a reduced 0.5rem radius to maintain structural integrity while staying consistent with the theme.

## Components
- **Primary Buttons:** Pill-shaped, solid #d19a03 with dark Sora Bold text. On press, they should slightly shrink (scale: 0.96) for a tactile feel.
- **Secondary Buttons:** Pill-shaped, solid #6f8f3f (Tactical Olive) for confirmations and utility actions.
- **Upload Progress:** A sleek 4px rectangular track. The "filled" portion should be solid #d19a03 with a leading white glow effect to suggest movement.
- **Status Chips:** High-contrast pill-shaped containers. "Completed" states utilize Tactical Olive backgrounds, while "Processing" uses a glass chip with a pulsing gold dot.
- **Input Fields:** Dark neutral background with a 1px white border at 10% opacity and 1rem corner radius. Upon focus, the border glows Industrial Gold.
- **Navigation Bar:** A floating glass panel anchored to the bottom of the screen with a heavy backdrop blur (30px) and active icons highlighted in Gold.
- **Video Cards:** Edge-to-edge thumbnails with 0.5rem (rounded-sm) corners, featuring a glassmorphic metadata overlay at the bottom.