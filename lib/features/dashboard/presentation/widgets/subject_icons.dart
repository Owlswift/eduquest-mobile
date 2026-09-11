// Hand-authored SVG icon tiles for the Learn screen's subject grid.
// Kept as raw SVG (rendered via flutter_svg) rather than Material icons so
// they match the supplied design pixel-for-pixel instead of approximating it.

const _defs = '''
<defs>
  <linearGradient id="blueTile" x1="5" y1="4" x2="43" y2="45" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#3978ed"/>
    <stop offset=".38" stop-color="#2469e8"/>
    <stop offset="1" stop-color="#0b55dc"/>
  </linearGradient>
  <linearGradient id="goldTile" x1="5" y1="4" x2="44" y2="46" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#fff2d2"/>
    <stop offset=".52" stop-color="#ffebc4"/>
    <stop offset="1" stop-color="#ffe4b3"/>
  </linearGradient>
  <linearGradient id="greenTile" x1="4" y1="4" x2="44" y2="46" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#e0f8e9"/>
    <stop offset=".5" stop-color="#d5f4e2"/>
    <stop offset="1" stop-color="#c9edd9"/>
  </linearGradient>
  <linearGradient id="purpleTile" x1="4" y1="4" x2="44" y2="46" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#f1e7ff"/>
    <stop offset=".5" stop-color="#eadbfc"/>
    <stop offset="1" stop-color="#e2d0fa"/>
  </linearGradient>
  <linearGradient id="paleBlueTile" x1="4" y1="4" x2="44" y2="46" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#edf4ff"/>
    <stop offset=".5" stop-color="#e5effd"/>
    <stop offset="1" stop-color="#dce9fb"/>
  </linearGradient>
  <linearGradient id="fxInk" x1="12" y1="10" x2="38" y2="38" gradientUnits="userSpaceOnUse">
    <stop stop-color="#fff"/>
    <stop offset=".55" stop-color="#f7fbff"/>
    <stop offset="1" stop-color="#dceaff"/>
  </linearGradient>
  <linearGradient id="goldInk" x1="16" y1="14" x2="34" y2="35" gradientUnits="userSpaceOnUse">
    <stop stop-color="#ffb42b"/>
    <stop offset=".65" stop-color="#f59a08"/>
    <stop offset="1" stop-color="#df8300"/>
  </linearGradient>
  <linearGradient id="greenInk" x1="15" y1="12" x2="34" y2="38" gradientUnits="userSpaceOnUse">
    <stop stop-color="#24b86e"/>
    <stop offset=".6" stop-color="#16a45d"/>
    <stop offset="1" stop-color="#0b8f4d"/>
  </linearGradient>
  <linearGradient id="purpleInk" x1="15" y1="11" x2="35" y2="38" gradientUnits="userSpaceOnUse">
    <stop stop-color="#8c43f1"/>
    <stop offset=".6" stop-color="#7530dc"/>
    <stop offset="1" stop-color="#6020c4"/>
  </linearGradient>
  <linearGradient id="blueInk" x1="16" y1="12" x2="34" y2="38" gradientUnits="userSpaceOnUse">
    <stop stop-color="#1766e8"/>
    <stop offset=".6" stop-color="#0757dc"/>
    <stop offset="1" stop-color="#0048c7"/>
  </linearGradient>
</defs>
''';

const String mathIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#blueTile)"/>
  <path d="M1.5 15C7 7 15 2 25 1.5h10c-9 2-18 7-24 14.5-4 5-7 11-9.5 17.5V15Z" fill="#fff" opacity=".055"/>
  <path d="M2 34c6 6.5 14 11 25 12h9c-10-2.2-18-6.5-25-13.2-4-3.8-6.8-8-9-12.5V34Z" fill="#003fae" opacity=".09"/>
  <g fill="url(#fxInk)">
    <path d="M20.45 15.1c.43-3.95 1.93-6.13 5.03-6.13 1.23 0 2.32.22 3.24.68l-.91 2.77c-.59-.24-1.2-.37-1.82-.37-1.38 0-2.08.91-2.38 2.72l-.31 1.48h4.13l-.66 3.06h-4.08l-2.74 13.26c-.63 3.06-2.1 4.57-4.66 4.57-1.21 0-2.32-.24-3.31-.73l.86-2.7c.63.28 1.27.42 1.9.42.94 0 1.55-.6 1.82-1.9l2.66-12.92h-2.78l.65-3.06h2.72l.54-1.15Z"/>
    <path d="m27.55 17.48 3.28 4.95 5.13-4.95h4.13l-7.58 7.02 4.98 7.58h-4.15l-3.17-5.06-5.37 5.06h-4.14l7.78-7.15-5.12-7.45h4.23Z"/>
  </g>
</svg>
''';

const String englishIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#goldTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".2"/>
  <path d="M4 39c6 5 14 8 24 9h7c-9-2.1-17-5.2-23-10-4-3.3-7-6.7-9-11v12Z" fill="#b96b00" opacity=".05"/>
  <g>
    <path d="M12.5 14.6c0-1.45 1.17-2.6 2.62-2.6h7.05c.74 0 1.43.31 1.91.82.48-.51 1.17-.82 1.91-.82h6.9c1.45 0 2.62 1.15 2.62 2.6v20.55c0 .83-.75 1.39-1.54 1.15-3.12-.96-6.3-1.06-9.52-.3-.24.06-.49.06-.73 0-3.22-.76-6.4-.66-9.52.3-.79.24-1.54-.32-1.54-1.15V14.6Z" fill="url(#goldInk)"/>
    <path d="M24.08 14.05c.48-.48 1.15-.75 1.9-.75.6 0 1.16.19 1.61.52v19.2c-1.18-.02-2.35.08-3.51.3V14.05Z" fill="#fff1cc" opacity=".34"/>
    <path d="M15.55 17.1c2.46-.5 4.8-.08 7.1 1.28v12.83c-2.36-.86-4.73-1.05-7.1-.56V17.1Zm17 0c-2.46-.5-4.8-.08-7.1 1.28v12.83c2.36-.86 4.73-1.05 7.1-.56V17.1Z" fill="#fff3d5" opacity=".28"/>
    <path d="M17.2 20.1h4.15M17.2 23.2h4.15M17.2 26.3h4.15M30.8 20.1h-4.15M30.8 23.2h-4.15M30.8 26.3h-4.15" stroke="#b86a06" stroke-width="1.35" stroke-linecap="round" opacity=".8"/>
    <path d="M12.8 34.4c3.8-1.06 7.53-1.06 11.2 0 3.67-1.06 7.4-1.06 11.2 0" fill="none" stroke="#d57d00" stroke-width="1.9" stroke-linecap="round"/>
  </g>
</svg>
''';

const String physicsIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#greenTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".2"/>
  <path d="M3 37c6 6 14 9.5 25 10h8c-10-2.1-18-6.3-24-12.4-4-4-7-8-9-13v15.4Z" fill="#188f50" opacity=".045"/>
  <g>
    <g fill="none" stroke="url(#greenInk)" stroke-width="2.35" stroke-linecap="round">
      <ellipse cx="24" cy="25" rx="13.6" ry="5.9" transform="rotate(30 24 25)"/>
      <ellipse cx="24" cy="25" rx="13.6" ry="5.9" transform="rotate(-30 24 25)"/>
      <ellipse cx="24" cy="25" rx="13.6" ry="5.9"/>
    </g>
    <circle cx="24" cy="25" r="5.1" fill="url(#greenInk)"/>
    <circle cx="22.45" cy="23.5" r="1.45" fill="#dff8e9" opacity=".8"/>
    <circle cx="27.3" cy="26.7" r="1.05" fill="#087f45" opacity=".72"/>
    <circle cx="10.9" cy="20.7" r="2.15" fill="url(#greenInk)"/>
    <circle cx="37.1" cy="20.7" r="2.15" fill="url(#greenInk)"/>
    <circle cx="24" cy="38.05" r="2.15" fill="url(#greenInk)"/>
  </g>
</svg>
''';

const String chemistryIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#purpleTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".2"/>
  <path d="M4 39c6 5 14 8 24 9h7c-9-2.1-17-5.2-23-10-4-3.3-7-6.7-9-11v12Z" fill="#6321c2" opacity=".045"/>
  <g>
    <path d="M20.3 10.8h7.4" stroke="#7731dd" stroke-width="2.6" stroke-linecap="round"/>
    <path d="M21.5 11.3v9.55l-7.15 11.65c-.9 1.47.16 3.35 1.88 3.35h15.54c1.72 0 2.78-1.88 1.88-3.35L26.5 20.85V11.3" fill="none" stroke="url(#purpleInk)" stroke-width="2.6" stroke-linejoin="round"/>
    <path d="M15.25 29.05c3.05-1.15 5.28 1.04 8.02.08 2.3-.8 4.45-.94 7.55.1l1.75 3.2c.42.77-.14 1.69-1.02 1.69H16.45c-.88 0-1.44-.92-1.02-1.69l-.18-.32Z" fill="url(#purpleInk)"/>
    <circle cx="26.8" cy="25.1" r="1.25" fill="#cdb1fa"/>
  </g>
</svg>
''';

const String biologyIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#greenTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".2"/>
  <g fill="url(#greenInk)">
    <path d="M20.6 11.2c3.9 0 6.3 2.6 6.3 6.25 0 2.4-1.15 4.05-2.9 5.15-1.72-1.1-2.8-2.75-2.8-5.15 0-3.65-.1-4.55-.6-6.25Z"/>
    <path d="M25.6 20.5c3.5-3.55 7.7-3.35 9.7-.35-1.6 3.6-5.1 5.45-9.7 4.3v-3.95Z"/>
    <path d="M22.4 22.8c-4.25-2.2-8.2-.45-8.8 3.2 2.7 2.85 6.45 3.1 9.65.72l-.85-3.92Z"/>
    <path d="M20.6 26.1h6.8l2.25 6.55c.3.88-.36 1.8-1.29 1.8h-8.72c-.93 0-1.59-.92-1.29-1.8l2.25-6.55Z"/>
    <circle cx="13.1" cy="33.1" r="2.2"/><circle cx="34.9" cy="32.5" r="2.2"/><circle cx="24" cy="38" r="2.2"/>
    <path d="M15 38h18" stroke="url(#greenInk)" stroke-width="2.4" stroke-linecap="round"/>
  </g>
</svg>
''';

const String economicsIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#purpleTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".2"/>
  <g>
    <rect x="13.5" y="12" width="21" height="23" rx="5.1" fill="url(#purpleInk)"/>
    <rect x="17.2" y="15.8" width="13.6" height="15.2" rx="2" fill="#f7efff" opacity=".96"/>
    <path d="M20 26.8v-5.2M23.9 26.8v-8.2M27.8 26.8v-3.7" stroke="#7c35df" stroke-width="2" stroke-linecap="round"/>
    <path d="m19.5 27.7 3.2-4 2.1 1.8 3.8-5" fill="none" stroke="#9b5aee" stroke-width="1.35" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>
''';

const String governmentIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#paleBlueTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".28"/>
  <g fill="url(#blueInk)">
    <path d="m24 10 12.5 6.6h-25L24 10Z"/>
    <path d="M10.2 17.4h27.6v2.2H10.2z"/>
    <path d="M13.1 19.7h4v13.6h-4zM21.9 19.7h4v13.6h-4zM30.8 19.7h4v13.6h-4z"/>
    <path d="M9.3 33.2h29.4v2.45H9.3z"/>
    <path d="M7.6 37.2h32.8v2H7.6z"/>
  </g>
</svg>
''';

const String moreIconSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_defs
  <rect x=".5" y=".5" width="47" height="47" rx="13" fill="url(#paleBlueTile)"/>
  <path d="M2 14C7 7 15 2 25 1.5h10c-9 2.1-17 6.6-23 13.7C7.7 20 4.6 27 2 34V14Z" fill="#fff" opacity=".3"/>
  <g fill="#175ab9">
    <circle cx="15" cy="24" r="2.25"/><circle cx="24" cy="24" r="2.25"/><circle cx="33" cy="24" r="2.25"/>
  </g>
</svg>
''';

const String bellIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" stroke="#ffffff" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="#ffffff" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
