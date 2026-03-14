class JobCategoryModel {
  final String categoryId;
  final String categoryName;

  JobCategoryModel({required this.categoryId, required this.categoryName});

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'category_id': categoryId, 'category_name': categoryName};
  }
}
