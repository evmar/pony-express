#!/usr/bin/python

import re

SHRINK = False

TEMPLATE = """
<!DOCTYPE html>
<style>@@../view.css@@</style>

<body>
<div id=threadlist></div>
<div id=message></div>

<script>@@../status2.js@@
@@../view.js@@
@@../pipermail.js@@
@@hijack.js@@

pipermail.status = function(text) {
  if (text) status2.show(text);
  else status2.clear();
}

var pm = isPiperMail(document.location.href);

if (!pm.month) {
  pipermail.loadIndex(pm.base, function(urls) {
    pipermail.loadMonth(urls[0], function(threads) {
      buildThreadList(threads);
    })
  });
} else if (!pm.thread) {
  pipermail.loadMonth('thread.html', function(threads) {
    buildThreadList(threads);
  })
} else {
  pipermail.loadMonth(pm.base + pm.month + '/thread.html', function(threads) {
    buildThreadList(threads);
    showThreadByURL(pm.url);
  })
}

</script>
</body>
"""

def ExpandTemplate(template):
    parts = []
    for i, part in enumerate(TEMPLATE.strip().split('@@')):
        if i % 2 == 1:
            part = open(part).read()
        parts.append(part)
    return ''.join(parts)


def HTMLStringEscape(text):
    text = text.replace('\\', '\\\\')
    text = text.replace('"', r'\"')
    if SHRINK:
        text = re.sub(r'\n+ *', ' ', text)
    else:
        text = text.replace('\n', '\\n\\\n')
    return text

print '// Generated by pack.py, do not edit.'
print 'var ui = "%s";' % HTMLStringEscape(ExpandTemplate(TEMPLATE))