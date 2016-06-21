Pod::Spec.new do |s|
  s.name             = "FeedParser"
  s.version          = "0.0.1"
  s.summary          = "FeedParser is an NSXMLParser-based RSS/Atom feed parser for Cocoa. It is intended to parse well-formed RSS and Atom feeds on both the desktop and the iPhone."
  s.homepage         = "https://github.com/terhechte/feedparser"
  s.license          = 'MIT'
  s.source           = { :git => "https://github.com/terhechte/feedparser.git", :tag => s.version.to_s }
  s.authors          = {'Kevin Ballard' => 'kevin@sb.org'}

  s.requires_arc = true

  s.source_files = 'FeedParser/**/*.{h,m}', './FeedParserFramework/*.{h,m}'

end