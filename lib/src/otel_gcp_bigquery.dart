// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_bigquery_suppression.dart';

class GcpBigQueryResult {
  const GcpBigQueryResult({
    this.project,
    this.dataset,
    this.table,
    this.jobId,
    this.jobType,
    this.statementType,
    this.bytesProcessed,
    this.bytesBilled,
    this.totalRows,
    this.rowsAffected,
    this.location,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? project;
  final String? dataset;
  final String? table;
  final String? jobId;
  final String? jobType;
  final String? statementType;
  final int? bytesProcessed;
  final int? bytesBilled;
  final int? totalRows;
  final int? rowsAffected;
  final String? location;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class GcpBigQueryCallResult<T> {
  const GcpBigQueryCallResult({required this.value, this.result});
  final T value;
  final GcpBigQueryResult? result;
}

Future<T> tracedGcpBigQuery<T>({
  required String operation,
  required Future<GcpBigQueryCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (gcpBigQueryInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_gcp_bigquery');
  final span = t.startSpan('bigquery $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'bigquery');
    span.setStringAttribute('gcp.service', 'bigquery');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.setStringAttribute('gcp.project.id', res.project!);
      }
      if (res.dataset != null) {
        span.setStringAttribute('db.namespace', res.dataset!);
      }
      if (res.table != null) {
        span.setStringAttribute('db.collection.name', res.table!);
      }
      if (res.jobId != null) {
        span.setStringAttribute('gcp.bigquery.job.id', res.jobId!);
      }
      if (res.jobType != null) {
        span.setStringAttribute('gcp.bigquery.job.type', res.jobType!);
      }
      if (res.statementType != null) {
        span.setStringAttribute('db.operation.name', res.statementType!);
      }
      if (res.bytesProcessed != null) {
        span.setIntAttribute(
          'gcp.bigquery.bytes_processed',
          res.bytesProcessed!,
        );
      }
      if (res.bytesBilled != null) {
        span.setIntAttribute('gcp.bigquery.bytes_billed', res.bytesBilled!);
      }
      if (res.totalRows != null) {
        span.setIntAttribute('gcp.bigquery.total_rows', res.totalRows!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.location != null) {
        span.setStringAttribute('cloud.region', res.location!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('bigquery.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'bigquery.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
