import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_utils.dart';

void main() {
  group('InstanceResolutionUsecase', () {
    test('resolveInBatches aggregates non-null resolved values', () async {
      final snapshots = <List<int>>[];

      final resolved = await resolveInBatches<int, int>(
        source: const [1, 2, 3, 4, 5],
        batchSize: 2,
        resolver: (value) async => value.isEven ? value * 10 : null,
        onBatchResolved: (items) => snapshots.add(items),
      );

      expect(resolved, [20, 40]);
      expect(snapshots, [
        [20],
        [20, 40],
        [20, 40],
      ]);
    });
  });
}
