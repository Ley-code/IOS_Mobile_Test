class JobFormData {
  final String projectTitle;
  final String description;
  final String locationPreference;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final List<String> selectedPlatforms;
  final List<String> selectedVisibility;
  final String? city;
  final String? state;
  final String? targetAudience;

  JobFormData({
    required this.projectTitle,
    required this.description,
    required this.locationPreference,
    this.selectedCategoryId,
    this.selectedCategoryName,
    required this.selectedPlatforms,
    required this.selectedVisibility,
    this.city,
    this.state,
    this.targetAudience,
  });
}
