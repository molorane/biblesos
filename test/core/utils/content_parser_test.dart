import 'package:test/test.dart';
import 'package:biblesos/core/utils/content_parser.dart';

void main() {
  group('ContentParser', () {
    test('should parse heading correctly', () {
      final content = '[H]Main Title[/H]';
      final blocks = ContentParser.parse(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, ContentType.heading);
      expect(blocks[0].text, 'Main Title');
    });

    test('should parse bible references correctly', () {
      final content = '[B]John 3:16[/B]';
      final blocks = ContentParser.parse(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, ContentType.bibleReference);
      expect(blocks[0].text, 'John 3:16');
    });

    test('should parse list items correctly', () {
      final content = '[LI]Step 1[/LI]';
      final blocks = ContentParser.parse(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, ContentType.listItem);
      expect(blocks[0].text, 'Step 1');
    });

    test('should handle nested/multiple tags in a line', () {
      final content = '[LI]Read [B]John 3:16[/B][/LI]';
      // The parser now correctly captures the whole LI including inner tags.
      final blocks = ContentParser.parse(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, ContentType.listItem);
      expect(blocks[0].text, 'Read [B]John 3:16[/B]');
    });

    test('should handle multiple references in one line', () {
      final content = '[B]John 1[/B]; [B]John 2[/B]';
      final blocks = ContentParser.parse(content);
      expect(blocks.length, 3); // [B], "; ", [B]
      expect(blocks[0].type, ContentType.bibleReference);
      expect(blocks[1].type, ContentType.text);
      expect(blocks[2].type, ContentType.bibleReference);
    });
  });
}
