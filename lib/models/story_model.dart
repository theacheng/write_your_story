import 'dart:convert';

class StoryModel {
  final int id;
  final String title;
  final String? paragraph;
  final DateTime createOn;
  final DateTime? updateOn;
  final DateTime forDate;
  final bool isFavorite;
  final String? feeling;

  /// this value isn't use anymore
  final bool isShare;

  const StoryModel({
    required this.id,
    required this.title,
    required this.paragraph,
    required this.createOn,
    required this.forDate,
    this.feeling,
    this.updateOn,
    this.isFavorite = false,
    this.isShare = false,
  });

  static StoryModel get empty {
    return StoryModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: "",
      paragraph: "",
      createOn: DateTime.now(),
      forDate: DateTime.now(),
      feeling: null,
    );
  }

  StoryModel copyWith({
    int? id,
    String? title,
    String? paragraph,
    DateTime? createOn,
    DateTime? updateOn,
    DateTime? forDate,
    bool? isFavorite,
    bool? isShare,
    String? feeling,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title != null ? title : this.title,
      paragraph: paragraph != null ? paragraph : this.paragraph,
      createOn: createOn ?? this.createOn,
      forDate: forDate ?? this.forDate,
      updateOn: updateOn ?? this.updateOn,
      isFavorite: isFavorite ?? this.isFavorite,
      isShare: isShare ?? this.isShare,
      feeling: feeling ?? this.feeling,
    );
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final DateTime createOn = DateTime.fromMillisecondsSinceEpoch(
      json["create_on"],
    );

    final DateTime forDate = DateTime.fromMillisecondsSinceEpoch(
      json["for_date"],
    );

    final DateTime? updateOn =
        json.containsKey('update_on') && json['update_on'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json["update_on"],
              )
            : null;

    bool isFavorite = false;
    if (json.containsKey("is_favorite")) {
      isFavorite = json["is_favorite"] == 1 ? true : false;
    }

    bool isShare = false;
    if (json.containsKey("is_share")) {
      isShare = json["is_share"] == 1 ? true : false;
    }

    return StoryModel(
      id: json["id"],
      title: json["title"],
      paragraph: json["paragraph"],
      updateOn: updateOn,
      createOn: createOn,
      forDate: forDate,
      isFavorite: isFavorite,
      isShare: isShare,
      feeling: json["feeling"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "paragraph": paragraph,
      "is_favorite": isFavorite ? 1 : 0,
      "create_on": createOn.millisecondsSinceEpoch,
      "for_date": forDate.millisecondsSinceEpoch,
      "update_on": updateOn != null ? updateOn!.millisecondsSinceEpoch : null,
      "feeling": feeling,
      "is_share": isShare ? 1 : 0,
    };
  }
}

List<StoryModel> storyModelFromJson(String str) {
  return List<StoryModel>.from(
    json.decode(str).map((x) => StoryModel.fromJson(x)),
  );
}

String storyModelToJson(List<StoryModel> data) {
  return json.encode(
    List<dynamic>.from(
      data.map(
        (x) => x.toJson(),
      ),
    ),
  );
}
