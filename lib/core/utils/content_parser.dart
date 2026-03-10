enum ContentType {
  text,
  heading,
  subHeading,
  bibleReference,
  verseText,
  quote,
  listItem,
  inlineAccent
}

class ContentBlock {
  final ContentType type;
  final String text;

  ContentBlock(this.type, this.text);
}

class ContentParser {
  static List<ContentBlock> parse(String content) {
    if (content.isEmpty) return [];
    
    List<ContentBlock> blocks = [];
    final regExp = RegExp(r'\[(H|S|B|b|T|Q|LI)\](.*?)(?:\[[\\/]\1\])', dotAll: true, caseSensitive: false);
    
    int lastMatchEnd = 0;
    
    for (final match in regExp.allMatches(content)) {
      if (match.start > lastMatchEnd) {
        String text = content.substring(lastMatchEnd, match.start).trim();
        if (text.isNotEmpty) {
          blocks.add(ContentBlock(ContentType.text, text));
        }
      }
      
      String tag = match.group(1)!;
      String innerText = match.group(2)!;
      
      ContentType type;
      switch (tag) {
        case 'H':
        case 'h': type = ContentType.heading; break;
        case 'S':
        case 's': type = ContentType.subHeading; break;
        case 'B': type = ContentType.bibleReference; break;
        case 'b': type = ContentType.inlineAccent; break;
        case 'T':
        case 't': type = ContentType.verseText; break;
        case 'Q':
        case 'q': type = ContentType.quote; break;
        case 'LI':
        case 'li': type = ContentType.listItem; break;
        default: type = ContentType.text;
      }
      
      blocks.add(ContentBlock(type, innerText));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < content.length) {
      String text = content.substring(lastMatchEnd).trim();
      if (text.isNotEmpty) {
        blocks.add(ContentBlock(ContentType.text, text));
      }
    }
    
    if (blocks.isEmpty && content.trim().isNotEmpty) {
      blocks.add(ContentBlock(ContentType.text, content.trim()));
    }
    
    return blocks;
  }
}
