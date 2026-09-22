// Generates site/privacy-policy.html from docs/play-store/privacy-policy.md.
//
//   dart run tool/build_privacy_policy.dart          # write the page
//   dart run tool/build_privacy_policy.dart --check  # exit 1 if it is stale
//
// The markdown file is the source of truth; the page is a build product.
// Only the markdown subset the policy actually uses is supported: `#`/`##`/
// `###` headings, paragraphs, `-` bullet lists, `**bold**`, `[text](url)`,
// `code`, bare URLs, an `_Last updated: …_` line, and `>` blockquotes
// (treated as maintainer notes and dropped from the page). Anything else is
// passed through as text, so keep the policy plain.
//
// No package imports: this runs with the SDK alone and must never pull a
// markdown or templating dependency into the app's dependency graph.

import 'dart:io';

const _sourcePath = 'docs/play-store/privacy-policy.md';
const _outputPath = 'site/privacy-policy.html';
const _repo = 'https://github.com/Inrego/SpeakrApp';
const _description =
    'Privacy policy for the Speakr app: no backend operated by us, no '
    'analytics, no third-party tracking. Your data goes only to the Speakr '
    'server you configure.';

void main(List<String> args) {
  final check = args.contains('--check');
  final source = File(_sourcePath).readAsStringSync();
  final html = render(source);
  final out = File(_outputPath);
  if (check) {
    final current = out.existsSync() ? out.readAsStringSync() : '';
    if (_normalise(current) != _normalise(html)) {
      stderr.writeln(
        '$_outputPath is out of date with $_sourcePath. '
        'Run: dart run tool/build_privacy_policy.dart',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('$_outputPath is up to date.');
    return;
  }
  out.writeAsStringSync(html);
  stdout.writeln('Wrote $_outputPath');
}

String _normalise(String s) => s.replaceAll('\r\n', '\n');

// ── Rendering ────────────────────────────────────────────────────────────────

String render(String markdown) {
  final lines = _normalise(markdown).split('\n');
  final body = StringBuffer();
  var title = 'Speakr — Privacy Policy';
  String? updated;

  final para = <String>[];
  final list = <String>[];
  var inQuote = false;

  void flushPara() {
    if (para.isEmpty) return;
    body.writeln('  <p>');
    body.writeln('    ${_inline(para.join(' '))}');
    body.writeln('  </p>');
    para.clear();
  }

  void flushList() {
    if (list.isEmpty) return;
    body.writeln('  <ul>');
    for (final item in list) {
      body.writeln('    <li>${_inline(item)}</li>');
    }
    body.writeln('  </ul>');
    list.clear();
  }

  void flushAll() {
    flushPara();
    flushList();
  }

  for (final raw in lines) {
    final line = raw.trimRight();

    // Blockquotes are maintainer notes; drop them, including their
    // continuation lines.
    if (line.startsWith('>')) {
      flushAll();
      inQuote = true;
      continue;
    }
    if (inQuote) {
      if (line.trim().isEmpty) {
        inQuote = false;
      }
      continue;
    }

    if (line.trim().isEmpty) {
      flushAll();
      continue;
    }

    if (line.startsWith('# ')) {
      flushAll();
      title = line.substring(2).trim();
      body.writeln('  <h1>${_escape(title)}</h1>');
      continue;
    }
    if (line.startsWith('## ')) {
      flushAll();
      body.writeln();
      body.writeln('  <h2>${_inline(line.substring(3).trim())}</h2>');
      continue;
    }
    if (line.startsWith('### ')) {
      flushAll();
      body.writeln('  <h3>${_inline(line.substring(4).trim())}</h3>');
      continue;
    }

    final updatedMatch = RegExp(r'^_Last updated: (.+)_$').firstMatch(line);
    if (updatedMatch != null && updated == null) {
      flushAll();
      updated = updatedMatch.group(1)!.trim();
      body.writeln('  <p class="updated">Last updated: ${_escape(updated)}</p>');
      continue;
    }

    if (line.startsWith('- ')) {
      flushPara();
      list.add(line.substring(2).trim());
      continue;
    }
    if (list.isNotEmpty && line.startsWith('  ')) {
      // Continuation of the previous bullet.
      list[list.length - 1] = '${list.last} ${line.trim()}';
      continue;
    }

    flushList();
    para.add(line.trim());
  }
  flushAll();

  return _page(title: title, body: body.toString());
}

/// Inline markdown → HTML. Order matters: escape first, then typographic
/// quotes (before any attribute quotes exist), then links, bold, code, and
/// finally bare URLs and e-mail addresses that are not already inside a tag.
String _inline(String text) {
  var s = _escape(text);
  s = s.replaceAllMapped(
    RegExp(r'"([^"]*)"'),
    (m) => '&ldquo;${m.group(1)}&rdquo;',
  );
  s = s.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\(([^)\s]+)\)'),
    (m) => '<a href="${m.group(2)}">${m.group(1)}</a>',
  );
  s = s.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
    (m) => '<strong>${m.group(1)}</strong>',
  );
  s = s.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (m) => '<code>${m.group(1)}</code>',
  );
  s = s.replaceAllMapped(
    RegExp(r'(?<![">=/\w])(https?://[^\s<]+)'),
    (m) => '<a href="${m.group(1)}">${m.group(1)}</a>',
  );
  s = s.replaceAllMapped(
    RegExp(r'(?<![":\w@])([\w.+-]+@[\w-]+\.[\w.-]*\w)'),
    (m) => '<a href="mailto:${m.group(1)}">${m.group(1)}</a>',
  );
  return s;
}

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

// ── Page shell ───────────────────────────────────────────────────────────────
//
// Self-contained on purpose: no CDN, no analytics, no web fonts. The brand
// families are named first in the font stacks so they are used if installed,
// otherwise the system fallback applies. Keep it that way.

String _page({required String title, required String body}) {
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_escape(title)}</title>
<meta name="description" content="$_description">
<style>
  :root {
    --bg: #FAFAF7;
    --bg-alt: #F3F1EC;
    --ink: #1A1A1A;
    --ink-2: #3A3A36;
    --muted: #8A8A83;
    --line: #E6E3DC;
    --accent: #C2562B;
  }
  * { box-sizing: border-box; }
  html { -webkit-text-size-adjust: 100%; }
  body {
    margin: 0;
    background: var(--bg);
    color: var(--ink-2);
    font-family: "Inter Tight", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 17px;
    line-height: 1.65;
  }
  .wrap { max-width: 42rem; margin: 0 auto; padding: 3rem 1.25rem 4rem; }
  h1, h2, h3 {
    font-family: "Source Serif 4", Georgia, "Times New Roman", serif;
    font-weight: 600;
    color: var(--ink);
    line-height: 1.25;
    letter-spacing: -0.01em;
  }
  h1 { font-size: 2.05rem; margin: 0 0 0.4rem; }
  h2 { font-size: 1.25rem; margin: 2.4rem 0 0.6rem; }
  h3 { font-size: 1.05rem; margin: 1.6rem 0 0.5rem; }
  .updated {
    font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    font-size: 0.75rem;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--muted);
    margin: 0 0 2rem;
  }
  p { margin: 0 0 1rem; }
  ul { margin: 0 0 1rem; padding-left: 1.15rem; }
  li { margin-bottom: 0.5rem; }
  strong { color: var(--ink); font-weight: 600; }
  code {
    font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    font-size: 0.85em;
    background: var(--bg-alt);
    padding: 0.1em 0.35em;
    border-radius: 3px;
  }
  a { color: var(--accent); text-underline-offset: 0.18em; word-break: break-word; }
  a:hover { color: var(--ink); }
  .back {
    display: inline-block;
    margin-bottom: 2rem;
    font-size: 0.85rem;
    color: var(--muted);
    text-decoration: none;
  }
  .back:hover { color: var(--ink); }
  footer {
    margin-top: 3rem;
    padding-top: 1.25rem;
    border-top: 1px solid var(--line);
    font-size: 0.85rem;
    color: var(--muted);
  }
  @media (max-width: 30rem) {
    .wrap { padding: 2rem 1rem 3rem; }
    h1 { font-size: 1.75rem; }
    body { font-size: 16px; }
  }
</style>
</head>
<body>
<main class="wrap">
  <a class="back" href="./">&larr; Speakr</a>

$body
  <footer>
    The canonical source of this policy is
    <a href="$_repo/blob/main/$_sourcePath">$_sourcePath</a>
    in the Speakr repository. This page is generated from it.
  </footer>
</main>
</body>
</html>
''';
}
