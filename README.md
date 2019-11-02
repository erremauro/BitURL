#  BitURL

A macOS 10.14+ agent to shorten long URLs using the [Bitly](http://bitly.com) 
API Service.

To shorten a URL call:

```
biturl://shorten/{longURL}
```

This will shorten `{longURL}` using Bitly API Service and copy the shorten url 
result into the clipboard.

To reverse a bitly link call:

```
biturl://reverse/{bitlyURL}
```

This will reverse `{bitlyURL}` to its original long url format and copy the 
result into the clipboard.

## Installation

[Download][Releases] the latest release of BitURL, double click the downloaded 
`.dmg` image file and drag `BitURL.app` into you `/Applications` folder.

If you are an [Alfred][AlfredApp] user, double click the `BitURL.alfredworkflow`
package to install an Alfred workflow that shorten and reverse URLS using BitURL.

[Releases]: https://github.com/erremauro/BitURL/releases
[AlfredApp]: https://alfredapp.com
