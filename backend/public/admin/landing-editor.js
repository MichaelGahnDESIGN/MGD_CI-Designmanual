(() => {
  'use strict';

  const localFontOptions = [
    { id: 'Open Sans', name: 'Open Sans' },
    { id: 'Lato', name: 'Lato' },
    { id: 'Montserrat', name: 'Montserrat' },
    { id: 'Merriweather', name: 'Merriweather' },
  ];

  function fallbackCss() {
    return `
      .mgd-page{font-family:'Open Sans',sans-serif;background:#f6f5f2;color:#111114;min-height:100vh;padding:12vw 10vw}
      .mgd-hero{max-width:760px}
      .mgd-eyebrow{font:600 14px 'Open Sans';letter-spacing:.12em}
      .mgd-hero h1{font:700 clamp(48px,8vw,108px)/.92 'Open Sans';margin:32px 0}
      .mgd-hero p:not(.mgd-eyebrow){font-size:18px;line-height:1.6;max-width:560px}
      .mgd-button{display:inline-block;background:#111114;color:#fffefc;border-radius:999px;padding:15px 22px;margin-top:18px}`;
  }

  // Der Fallback hält den Editor bedienbar, solange für eine Sprache noch
  // kein veröffentlichtes CMS-Dokument existiert. Deutsch ist Standard.
  const fallback = {
    de: {
      html: `
        <main class="mgd-page">
          <section class="mgd-hero">
            <p class="mgd-eyebrow">MARKENHANDHABUNG MIT HALTUNG.</p>
            <h1>Dein Markenmanual.<br>Klar. Konsistent.<br>Bereit für überall.</h1>
            <p>Markenwissen wird zu einem editierbaren Designmanual und Social-Media-Codex.</p>
            <a class="mgd-button">Projekt starten</a>
          </section>
        </main>`,
      css: fallbackCss(),
    },
    en: {
      html: `
        <main class="mgd-page">
          <section class="mgd-hero">
            <p class="mgd-eyebrow">BRAND SYSTEMS WITH INTENT.</p>
            <h1>Your brand manual.<br>Clear. Consistent.<br>Ready for everywhere.</h1>
            <p>Turn brand knowledge into an editable design manual and social media codex.</p>
            <a class="mgd-button">Start a project</a>
          </section>
        </main>`,
      css: fallbackCss(),
    },
  };

  let locale = 'de';
  const state = document.querySelector('#save-state');

  const editor = grapesjs.init({
    container: '#gjs',
    height: '100%',
    storageManager: false,
    fromElement: false,
    canvas: {
      // Die Schriftdefinitionen werden auch in den isolierten Grapes.js-
      // Canvas geladen. Damit erzeugt die Vorschau keine externen Requests.
      styles: ['vendor/fonts/fonts.css'],
    },
    blockManager: {
      appendTo: '.gjs-pn-views',
      blocks: [
        {
          id: 'hero',
          label: 'Hero',
          category: 'CI BUILDER',
          content:
            '<section class="mgd-hero"><h1>Neue Überschrift</h1><p>Dein Text.</p></section>',
        },
        {
          id: 'section',
          label: 'Abschnitt',
          category: 'CI BUILDER',
          content:
            '<section class="mgd-section"><h2>Abschnitt</h2><p>Inhalt ergänzen.</p></section>',
        },
        {
          id: 'button',
          label: 'Button',
          category: 'CI BUILDER',
          content: '<a class="mgd-button">Aktion</a>',
        },
      ],
    },
    styleManager: {
      sectors: [
        {
          name: 'Typografie',
          open: true,
          properties: [
            {
              property: 'font-family',
              name: 'Schrift',
              type: 'select',
              default: 'Open Sans',
              options: localFontOptions,
            },
            { property: 'font-size', name: 'Größe' },
            { property: 'font-weight', name: 'Stärke' },
            { property: 'line-height', name: 'Zeilenhöhe' },
            { property: 'letter-spacing', name: 'Laufweite' },
            { property: 'color', name: 'Textfarbe' },
          ],
        },
        {
          name: 'Abstände',
          open: false,
          properties: ['margin', 'padding'],
        },
        {
          name: 'Fläche',
          open: false,
          properties: ['background-color', 'border', 'border-radius'],
        },
      ],
    },
  });

  function setState(text) {
    state.textContent = text;
  }

  async function load(nextLocale) {
    locale = nextLocale;
    setState(`Lade ${locale.toUpperCase()} …`);
    let content = fallback[locale];

    try {
      const response = await fetch(`../api/cms/landing?locale=${locale}`, {
        credentials: 'same-origin',
      });
      if (response.ok) {
        const remote = await response.json();
        content = remote.content || content;
      }
    } catch (_) {
      // Der lokale Fallback ist für Offline- und Erstinstallationen vorgesehen.
    }

    editor.setComponents(content.html);
    editor.setStyle(content.css);
    setState(`${locale.toUpperCase()} · Entwurf geladen`);
  }

  async function publish() {
    setState('Speichere …');
    const csrf =
      document.cookie
        .split('; ')
        .find((entry) => entry.startsWith('ci_builder_csrf='))
        ?.split('=')[1] || '';

    try {
      const response = await fetch('../api/cms/landing', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrf,
        },
        body: JSON.stringify({
          locale,
          html: editor.getHtml(),
          css: editor.getCss(),
        }),
      });
      if (!response.ok) throw new Error('publish_failed');
      setState(`${locale.toUpperCase()} · Veröffentlicht`);
    } catch (_) {
      setState('Nicht gespeichert · Admin-Login erforderlich');
    }
  }

  document.querySelector('#save-button').addEventListener('click', publish);
  document
    .querySelector('#language-de')
    .addEventListener('click', () => load('de'));
  document
    .querySelector('#language-en')
    .addEventListener('click', () => load('en'));
  document.querySelector('#theme-toggle').addEventListener('click', () => {
    document.body.classList.toggle('dark');
  });

  load('de');
})();
