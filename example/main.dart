// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gcp_bigquery/otel_gcp_bigquery.dart';

/// Traces Gcp Bigquery calls with OpenTelemetry.
///
/// `otel_gcp_bigquery` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Gcp Bigquery call in
/// [tracedGcpBigQuery]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gcp-bigquery-example');

  // Traces a Gcp Bigquery call.
  final gcpBigQueryId = await tracedGcpBigQuery<String>(
    operation: 'create',
    invoke: () async {
      // Make the Gcp Bigquery call here, then report what it returned.
      const id = 'gcp_bigquery_8f3a2c';
      return const GcpBigQueryCallResult(
          value: id,
          result: GcpBigQueryResult(
              project: 'example',
              dataset: 'example',
              table: 'orders',
              jobId: 'job_8f3a2c',
              jobType: 'standard',
              statementType: 'active',
              bytesProcessed: 512,
              bytesBilled: 512,
              totalRows: 1,
              rowsAffected: 1,
              location: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedGcpBigQuery create returned $gcpBigQueryId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGcpBigQueryInstrumentationAsync.
  await runWithoutGcpBigQueryInstrumentationAsync(
    () => tracedGcpBigQuery<String>(
      operation: 'create',
      invoke: () async {
        const id = 'gcp_bigquery_8f3a2c';
        return const GcpBigQueryCallResult(
            value: id,
            result: GcpBigQueryResult(
                project: 'example',
                dataset: 'example',
                table: 'orders',
                jobId: 'job_8f3a2c',
                jobType: 'standard',
                statementType: 'active',
                bytesProcessed: 512,
                bytesBilled: 512,
                totalRows: 1,
                rowsAffected: 1,
                location: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
