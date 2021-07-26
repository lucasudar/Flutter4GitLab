class Approvals {
  late int id;
  late int iid;
  late int projectId;
  late String title;
  late String description;
  late String state;
  late String createdAt;
  late String updatedAt;
  late String mergeStatus;
  late int approvalsRequired;
  late int approvalsLeft;
  late List<ApprovedBy> approvedBy = [];

  Approvals(
      {required this.id,
      required this.iid,
      required this.projectId,
      required this.title,
      required this.description,
      required this.state,
      required this.createdAt,
      required this.updatedAt,
      required this.mergeStatus,
      required this.approvalsRequired,
      required this.approvalsLeft,
      required this.approvedBy});

  Approvals.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iid = json['iid'];
    projectId = json['project_id'];
    title = json['title'];
    description = json['description'];
    state = json['state'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    mergeStatus = json['merge_status'];
    approvalsRequired = json['approvals_required'];
    approvalsLeft = json['approvals_left'];
    if (json['approved_by'] != null) {
      approvedBy = [];
      json['approved_by'].forEach((v) {
        approvedBy.add(new ApprovedBy.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['iid'] = this.iid;
    data['project_id'] = this.projectId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['state'] = this.state;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['merge_status'] = this.mergeStatus;
    data['approvals_required'] = this.approvalsRequired;
    data['approvals_left'] = this.approvalsLeft;
    if (this.approvedBy != null) {
      data['approved_by'] = this.approvedBy.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ApprovedBy {
  User? user;

  ApprovedBy({this.user});

  ApprovedBy.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  late String name;
  late String username;
  late int id;
  late String state;
  late String avatarUrl;
  late String webUrl;

  User(
      {required this.name,
      required this.username,
      required this.id,
      required this.state,
      required this.avatarUrl,
      required this.webUrl});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    id = json['id'];
    state = json['state'];
    avatarUrl = json['avatar_url'];
    webUrl = json['web_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['username'] = this.username;
    data['id'] = this.id;
    data['state'] = this.state;
    data['avatar_url'] = this.avatarUrl;
    data['web_url'] = this.webUrl;
    return data;
  }
}
