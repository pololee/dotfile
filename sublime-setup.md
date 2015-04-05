### Package Control

1. ctrl + ` open the console
2. Paste the code and run
```
import urllib.request,os,hashlib; h = 'eb2297e1a458f27d836c04bb0cbaf282' + 'd0e7a3098092775ccb37ca9d6b2e4b7d'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```
3. Package list
    - AlignTab
    - All Autocomplete
    - BracketHighlighter
    - Codecs33
    - ConvertToUTF8
    - DocBlockr
    - Emmet
    - ERB Snippets
    - GitGutter
    - HTML-CSS-JS Prettify
    - Markdown Extended
    - Monokai Extended
    - Sass
    - SideBarEnhancements
    - SublimeLinter
    - SyncedSideBar
    - TrailingSpaces
    - Vintageous
