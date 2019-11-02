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
