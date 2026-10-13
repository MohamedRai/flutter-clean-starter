import 'package:flutter_clean_starter/features/posts/data/models/post_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_fixtures.dart';

void main() {
  group('PostModel', () {
    test('fromJson decodes the API shape', () {
      expect(PostModel.fromJson(Fixtures.postJson), Fixtures.postModel);
    });

    test('toJson round-trips', () {
      expect(Fixtures.postModel.toJson(), Fixtures.postJson);
    });

    test('toEntity / fromEntity convert both ways', () {
      expect(Fixtures.postModel.toEntity(), Fixtures.post);
      expect(PostModel.fromEntity(Fixtures.post), Fixtures.postModel);
    });

    test('fromJson throws on a malformed payload', () {
      expect(
        () => PostModel.fromJson(const {'id': 'not-an-int'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
