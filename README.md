# otel_gcp_bigquery

Dartastic OpenTelemetry bridge for GCP BigQuery (serverless data warehouse).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_gcp_bigquery/otel_gcp_bigquery.dart';

await tracedGcpBigQuery<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return GcpBigQueryCallResult(value: r, result: GcpBigQueryResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutGcpBigQueryInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
