// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_gcp_bigquery/otel_gcp_bigquery.dart';
import 'package:test/test.dart';

void main() {
  group('otel_gcp_bigquery', () {
    test('suppression toggles in zone', () async {
      expect(gcpBigQueryInstrumentationSuppressed(), isFalse);
      await runWithoutGcpBigQueryInstrumentationAsync(() async {
        expect(gcpBigQueryInstrumentationSuppressed(), isTrue);
      });
      expect(gcpBigQueryInstrumentationSuppressed(), isFalse);
    });

    test('GcpBigQueryResult fields default null', () {
      const r = GcpBigQueryResult();
      expect(r.statusCode, isNull);
    });
  });
}
