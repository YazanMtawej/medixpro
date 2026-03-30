import 'package:dio/src/dio.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remote;

  ReportsRepositoryImpl(this.remote);

  @override
  Future<List<Report>> getReports() => remote.getReports();

  @override
  Future<Report> getReportDetail(int id) => remote.getReportDetail(id);

  @override
  Future<Report> addReport(Map<String, dynamic> data) => remote.addReport(data);

  @override
  Future<void> createReport(Report report) {
    // TODO: implement createReport
    throw UnimplementedError();
  }

  @override
  // TODO: implement dio
  Dio get dio => throw UnimplementedError();
}