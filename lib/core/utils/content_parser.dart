enum ContentType {
  text,
  heading,
  subHeading,
  bibleReference,
  verseText,
  quote
}

class ContentBlock {
  final ContentType type;
  final String text;

  ContentBlock(this.type, this.text);
}

class ContentParser {
  static List<ContentBlock> parse(String content) {
    List<ContentBlock> blocks = [];
    
    // Improved regex to handle:
    // 1. Standard tags: [B]text[/B]
    // 2. Typos: [B]text[\B]
    // 3. Simple closing: [B]text]
    // 4. Case insensitive: [b]text[/b]
    final regExp = RegExp(r'\[([HSBTQhsbtq])\](.*?)(?:\[[\\/]\1\]|\])', dotAll: true);
    
    int lastMatchEnd = 0;
    
    for (final match in regExp.allMatches(content)) {
      // Add text before the match as regular text if it's not empty
      if (match.start > lastMatchEnd) {
        String leadingText = content.substring(lastMatchEnd, match.start).trim();
        if (leadingText.isNotEmpty) {
          blocks.add(ContentBlock(ContentType.text, leadingText));
        }
      }
      
      String tag = match.group(1)!.toUpperCase();
      String text = match.group(2)!.trim();
      
      ContentType type;
      switch (tag) {
        case 'H':
          type = ContentType.heading;
          break;
        case 'S':
          type = ContentType.subHeading;
          break;
        case 'B':
          type = ContentType.bibleReference;
          break;
        case 'T':
          type = ContentType.verseText;
          break;
        case 'Q':
          type = ContentType.quote;
          break;
        default:
          type = ContentType.text;
      }
      
      blocks.add(ContentBlock(type, text));
      lastMatchEnd = match.end;
    }
    
    // Add remaining text after the last match
    if (lastMatchEnd < content.length) {
      String trailingText = content.substring(lastMatchEnd).trim();
      if (trailingText.isNotEmpty) {
        blocks.add(ContentBlock(ContentType.text, trailingText));
      }
    }
    
    // If no tags were found, treat the whole thing as regular text
    if (blocks.isEmpty && content.trim().isNotEmpty) {
      blocks.add(ContentBlock(ContentType.text, content.trim()));
    }
    
    return blocks;
  }
}
