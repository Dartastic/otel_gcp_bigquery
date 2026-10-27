// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_bigquery_suppression.dart';

class GcpBigQueryResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GcpBigQueryCallResult<T> {
  /// Creates a call result.
  const GcpBigQueryCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GcpBigQueryResult? result;
}

Future<T> tracedGcpBigQuery<T>({
  required String operation,
  required Future<GcpBigQueryCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (gcpBigQueryInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_gcp_bigquery');
  final span = t.startSpan('bigquery $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('db.system.name', 'bigquery')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gcp.service', 'bigquery')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.project.id', res.project!)]));
      }
      if (res.dataset != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.namespace', res.dataset!)]));
      }
      if (res.table != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.collection.name', res.table!)]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.bigquery.job.id', res.jobId!)]));
      }
      if (res.jobType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.bigquery.job.type', res.jobType!)]));
      }
      if (res.statementType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('db.operation.name', res.statementType!)
        ]));
      }
      if (res.bytesProcessed != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
            'gcp.bigquery.bytes_processed',
            res.bytesProcessed!,
          )
        ]));
      }
      if (res.bytesBilled != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('gcp.bigquery.bytes_billed', res.bytesBilled!)
        ]));
      }
      if (res.totalRows != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('gcp.bigquery.total_rows', res.totalRows!)]));
      }
      if (res.rowsAffected != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('db.response.returned_rows', res.rowsAffected!)
        ]));
      }
      if (res.location != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.location!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('bigquery.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'bigquery.error',
          )
        ]));
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
