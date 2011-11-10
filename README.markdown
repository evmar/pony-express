# Pony Express

To users, Pony Express is a Chrome extension that hijacks mailing list
archive URLs and rewrites them into a more pleasant UI.

In pictures, a page that looks like this:

![Screenshot](screenshot-before.png)

Transparently becomes a page that looks like this:

![Screenshot](screenshot.png)

Concretely, Pony Express is comprised of three modules:

1. A JavaScript library that takes JSON data describing mailing list
   content and creates a more pleasant UI for browsing it: a threaded
   view, shortcut keys for navigation.  This lives in `ui/`.  This is
   pretty preliminary at the moment.

2. A JavaScript library that extracts mailing list data out of
   Pipermail archive pages (like from the screenshot above).  This
   lives in `pipermail/`.  Conceptually, other archives (like hypermail)
   could plug in as well.

3. A Chrome extension that grabs URLs, feeds them into module 2, then
   feeds that into module 1.

