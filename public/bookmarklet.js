// RA-H Save Bookmarklet
// Drag the link below to your bookmarks bar, or copy the javascript: URL.
//
// When clicked on any page, it opens the RA-H Save tab pre-filled with
// the page title and URL.

// Minified bookmarklet code (copy everything on the next line as your bookmark URL):
// javascript:(function(){var t=encodeURIComponent(document.title),u=encodeURIComponent(window.location.href);window.open('https://ra-hos-production.up.railway.app/chat?tab=save&url='+u+'&title='+t,'_blank');})();

var BOOKMARKLET_URL = "javascript:(function(){var t=encodeURIComponent(document.title),u=encodeURIComponent(window.location.href);window.open('https://ra-hos-production.up.railway.app/chat?tab=save&url='+u+'&title='+t,'_blank');})();";

if (typeof module !== 'undefined') {
  module.exports = BOOKMARKLET_URL;
}
