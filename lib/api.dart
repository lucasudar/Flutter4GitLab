import 'dart:async';
import 'dart:convert';

import 'package:F4Lab/gitlab_client.dart';
import 'package:F4Lab/model/approvals.dart' hide User;
import 'package:F4Lab/model/diff.dart';
import 'package:F4Lab/model/jobs.dart';
import 'package:F4Lab/model/merge_request.dart';
import 'package:F4Lab/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class ApiResp<T> {
  bool success;
  T? data;
  String? err;

  ApiResp(this.success, [this.data, this.err]);
}

class ApiEndPoint {
  static const merge_request_states = ["opened", "closed", "locked", "merged"];
  static const merge_request_scopes = ["all", "assigned_to_me"];

  /// Get a project's all merge requests with state and scope filter
  /// [state] one of [merge_request_states]
  /// [scope] one of [merge_request_scopes]
  ///
  static String mergeRequests(int projectId,
          {required String state, required String scope}) =>
      "projects/$projectId/merge_requests?state=${state ?? "opened"}&scope=${scope ?? "all"}";

  static String singleMergeRequest(int projectId, int mrIId) =>
      "projects/$projectId/merge_requests/$mrIId?include_rebase_in_progress=true&include_diverged_commits_count=true";

  static String mergeRequestCommit(int projectId, int mrIID) =>
      "projects/$projectId/merge_requests/$mrIID/commits";

  static String mrApproveData(int projectId, int mrIId) =>
      'projects/$projectId/merge_requests/$mrIId/approvals';

  static String approveMergeRequest(int projectId, int mrIId, bool approve) =>
      "projects/$projectId/merge_requests/$mrIId/${approve ? "approve" : "unapprove"}";

  static String rebaseMR(int projectId, int mrIId) =>
      "projects/$projectId/merge_requests/$mrIId/rebase";

  static String mergeRequestPipelines(int projectId, int mrIId) =>
      "projects/$projectId/merge_requests/$mrIId/pipelines";

  static String pipelineJobs(int projectId, int pipelineId) =>
      "projects/$projectId/pipelines/$pipelineId/jobs";

  static String projectJobs(int projectId) => "projects/$projectId/jobs";

  static String mergeMR(
    int projectId,
    int mrIId, {
    bool shouldRemoveSourceBranch = false,
    bool mergeMrWhenPipelineSuccess = false,
    bool squash = false,
    String mergeCommitMessage = "",
  }) =>
      'projects/$projectId/merge_requests/$mrIId/merge?' +
      'should_remove_source_branch=$shouldRemoveSourceBranch' +
      '&merge_when_pipeline_succeeds=$mergeMrWhenPipelineSuccess' +
      '&squash=$squash' +
      '$mergeCommitMessage';

  static String cancelMergeMrWhenPipelineSuccess(int projectId, int mrIId) =>
      "projects/$projectId/merge_requests/$mrIId/cancel_merge_when_pipeline_succeeds";

  static String triggerPipelineJob(int projectId, int jobId, String action) =>
      "projects/$projectId/jobs/$jobId/$action";

  static String commitDiff(int projectId, String sha) =>
      "projects/$projectId/repository/commits/$sha/diff";

  static String mergeRequestDiscussion(int projectId, int mrIId) =>
      "projects/$projectId/merge_requests/$mrIId/discussions";
}

class ApiService {
  static bool respStatusIsOk(int statusCode) => (statusCode ~/ 100) == 2;

  static dynamic respConvertToUtf8(Response resp) =>
      utf8.decode(resp.bodyBytes);

  static Map<String, dynamic> respConvertToMap(Response resp) {
    if (!respStatusIsOk(resp.statusCode)) {
      throw Exception("Response error: ${resp.statusCode} ${resp.body}");
    }
    return jsonDecode(respConvertToUtf8(resp));
  }

  static List<dynamic> respConvertToList(Response resp) {
    if (!respStatusIsOk(resp.statusCode)) {
      throw Exception("Response error: ${resp.statusCode} ${resp.body}");
    }
    return jsonDecode(respConvertToUtf8(resp));
  }

  static Future<ApiResp<User>> getAuthUser() async {
    return GitlabClient.buildDio().get('user').then((resp) {
      debugPrint(resp.toString());
      final ok = respStatusIsOk(resp.statusCode!);
      return ApiResp(ok, User.fromJson(resp.data));
    }).catchError((err) => ApiResp<User>(false, null, err.toString()));
  }

  static Future<ApiResp<MergeRequest>> getSingleMR(int projectId, int mrIId) {
    final endPoint = ApiEndPoint.singleMergeRequest(projectId, mrIId);
    final client = GitlabClient.newInstance();
    return client.get(Uri.parse(endPoint)).then((resp) {
      return ApiResp(respStatusIsOk(resp.statusCode),
          MergeRequest.fromJson(respConvertToMap(resp)));
    }).catchError((err) {
      return ApiResp<MergeRequest>(false, null, err?.toString());
    }).whenComplete(client.close);
  }

  static Future<ApiResp> approve(
      int projectId, int mrIId, bool isApprove) async {
    final endPoint =
        ApiEndPoint.approveMergeRequest(projectId, mrIId, isApprove);
    final client = GitlabClient.newInstance();
    return client.post(Uri.parse(endPoint)).then((resp) {
      return ApiResp<String>(respStatusIsOk(resp.statusCode), resp.body,
          respStatusIsOk(resp.statusCode) ? "" : resp.body);
    }).catchError((err) {
      return ApiResp<String>(false, null, err?.toString());
    }).whenComplete(client.close);
  }

  static Future<ApiResp<void>> rebaseMr(int projectId, int mrIId) {
    final endPoint = ApiEndPoint.rebaseMR(projectId, mrIId);
    final client = GitlabClient.newInstance();
    return client
        .put(Uri.parse(endPoint))
        .then((resp) => ApiResp<void>(respStatusIsOk(resp.statusCode)))
        .whenComplete(client.close);
  }

  static Future<ApiResp<Approvals>> mrApproveData(int projectId, int mrIId) {
    final endPoint = ApiEndPoint.mrApproveData(projectId, mrIId);
    final client = GitlabClient.newInstance();
    return client
        .get(Uri.parse(endPoint))
        .then((resp) {
          return ApiResp(respStatusIsOk(resp.statusCode),
              Approvals.fromJson(respConvertToMap(resp)));
        })
        .catchError((err) => ApiResp<Approvals>(false, null, err?.toString()))
        .whenComplete(client.close);
  }

  static Future<ApiResp> acceptMR(int projectId, int mrIId,
      {bool shouldRemoveSourceBranch = false,
      bool mergeMrWhenPipelineSuccess = false,
      bool squash = false,
      String? mergeCommitMessage}) {
    final endPoint = ApiEndPoint.mergeMR(projectId, mrIId,
        shouldRemoveSourceBranch: shouldRemoveSourceBranch,
        mergeMrWhenPipelineSuccess: mergeMrWhenPipelineSuccess,
        mergeCommitMessage: mergeCommitMessage ?? "",
        squash: squash);
    final client = GitlabClient.newInstance();
    return client.put(Uri.parse(endPoint)).then((resp) {
      return ApiResp(respStatusIsOk(resp.statusCode));
    }).catchError((err) {
      return ApiResp<String>(false, null, err?.toString());
    }).whenComplete(client.close);
  }

  static Future<ApiResp<List<Jobs>>> pipelineJobs(
      int projectId, int pipelineId) {
    final endPoint = ApiEndPoint.pipelineJobs(projectId, pipelineId);
    return GitlabClient.buildDio()
        .get<List>(endPoint)
        .then((resp) =>
            ApiResp(true, resp.data!.map((it) => Jobs.fromJson(it)).toList()))
        .catchError((err) => ApiResp<List<Jobs>>(false, null, err));
  }

  static Future<ApiResp> triggerPipelineJob(
      int projectId, int jobId, String action) {
    final endPoint = ApiEndPoint.triggerPipelineJob(projectId, jobId, action);
    final client = GitlabClient.newInstance();
    return client
        .post(Uri.parse(endPoint))
        .then((resp) => ApiResp(respStatusIsOk(resp.statusCode)))
        .catchError((err) => ApiResp<ApiResp>(false, null, err?.toString()))
        .whenComplete(client.close);
  }

  static Future<ApiResp<List<Diff>>> commitDiff(int projectId, String sha) {
    final endPoint = ApiEndPoint.commitDiff(projectId, sha);
    return GitlabClient.buildDio()
        .get<List>(endPoint)
        .then((resp) => ApiResp(
            true, resp.data!.map((item) => Diff.fromJson(item)).toList()))
        .catchError((err) => ApiResp<List<Diff>>(false, null, err));
  }
}
