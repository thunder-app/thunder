import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/networking/modlog_parsers.dart';
import 'package:thunder/src/core/networking/mappers/lemmy_v3_mapper.dart';
import 'package:thunder/src/core/networking/mappers/lemmy_v4_mapper.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';

import '../../../helpers/api_fixtures/lemmy_v3_fixtures.dart';
import '../../../helpers/api_fixtures/lemmy_v4_fixtures.dart';

void main() {
  const v3Mapper = LemmyV3PrimitiveMapper();
  const v4Mapper = LemmyV4PrimitiveMapper();

  group('modlogEventsFromV3Response', () {
    test('parses grouped removed_posts events', () {
      final events = modlogEventsFromV3Response(
        {
          'removed_posts': [lemmyV3RemovedPostModlogEvent()],
          'locked_posts': [],
        },
        v3Mapper,
      );

      expect(events, hasLength(1));
      expect(events.first.type, ModlogActionType.modRemovePost);
      expect(events.first.reason, 'spam');
      expect(events.first.moderator?.name, 'mod');
    });
  });

  group('modlogEventFromV4', () {
    test('parses paginated v4 modlog item', () {
      final event = modlogEventFromV4(lemmyV4ModlogItem(), v4Mapper);

      expect(event, isNotNull);
      expect(event!.type, ModlogActionType.modRemovePost);
      expect(event.reason, 'spam');
      expect(event.moderator?.name, 'mod');
      expect(event.post?.name, 'Hello Lemmy 1.0');
    });

    test('returns null for unsupported payload', () {
      expect(
          modlogEventFromV4({
            'modlog': {'type_': 'unknown'}
          }, v4Mapper),
          isNull);
      expect(modlogEventFromV4('invalid', v4Mapper), isNull);
    });
  });
}
