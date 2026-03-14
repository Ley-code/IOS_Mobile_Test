import 'package:flutter/material.dart';
import 'package:mobile_app/features/job_creation/data/models/job_form_data.dart';
import 'package:mobile_app/features/job_creation/data/models/job_category_model.dart';
import 'package:mobile_app/features/job_creation/data/data_sources/remote/job_categories_remote_data_source.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'package:mobile_app/core/services/location_service.dart';
import 'package:mobile_app/core/widgets/city_autocomplete_field.dart';

class CreateProjectPage1 extends StatefulWidget {
  const CreateProjectPage1({super.key});

  @override
  State<CreateProjectPage1> createState() => _CreateProjectPage1State();
}

class _CreateProjectPage1State extends State<CreateProjectPage1> {
  final _projectTitleController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAudienceController = TextEditingController();

  String _locationPreference = 'National';
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<JobCategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  bool _isLoadingLocation = false;
  final List<String> _selectedPlatforms = [];
  final List<String> _selectedVisibility = ['Content Creators', 'Designers'];
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();
    _targetAudienceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final dataSource = JobCategoriesRemoteDataSourceImpl(apiClient: di.sl());
      final categories = await dataSource.getJobCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCategoryBottomSheet(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Category',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingCategories)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No categories available',
                    style: TextStyle(color: subtleText),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected =
                        _selectedCategoryId == category.categoryId;
                    return ListTile(
                      title: Text(
                        category.categoryName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: accent)
                          : null,
                      selected: isSelected,
                      selectedTileColor: accent.withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.categoryId;
                          _selectedCategoryName = category.categoryName;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.business_center,
                        color: accent,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create New Project',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Detail projects',
                      style: TextStyle(color: subtleText, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                'Project Title',
                'e.g., Summer Campaign Photoshoot',
                _projectTitleController,
                cardColor,
                textColor,
                subtleText,
              ),
              const SizedBox(height: 20),
              _buildLocationPreference(
                cardColor,
                accent,
                textColor,
                subtleText,
              ),
              const SizedBox(height: 20),
              _buildCityAndStateFields(
                cardColor,
                textColor,
                subtleText,
                accent,
              ),
              const SizedBox(height: 20),
              _buildProjectCategories(cardColor, accent, textColor, subtleText),
              const SizedBox(height: 20),
              _buildDescriptionField(cardColor, textColor, subtleText),
              const SizedBox(height: 20),
              _buildProjectPlatform(cardColor, accent, textColor),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate required fields
                    if (_projectTitleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a project title'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (_descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a project description'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Pass data to page 2
                    final jobFormData = JobFormData(
                      projectTitle: _projectTitleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      locationPreference: _locationPreference,
                      selectedCategoryId: _selectedCategoryId,
                      selectedCategoryName: _selectedCategoryName,
                      selectedPlatforms: _selectedPlatforms,
                      selectedVisibility: _selectedVisibility,
                      city: _cityController.text.trim().isEmpty
                          ? null
                          : _cityController.text.trim(),
                      state: _stateController.text.trim().isEmpty
                          ? null
                          : _stateController.text.trim(),
                      targetAudience:
                          _targetAudienceController.text.trim().isEmpty
                          ? null
                          : _targetAudienceController.text.trim(),
                    );

                    Navigator.pushNamed(
                      context,
                      '/create_project_page_2',
                      arguments: jobFormData,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: subtleText, fontSize: 14),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityAndStateFields(
    Color cardColor,
    Color textColor,
    Color subtleText,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CityAutocompleteField(
          label: 'City',
          hint: 'e.g., San Francisco',
          cityController: _cityController,
          stateController: _stateController,
          cardColor: cardColor,
          textColor: textColor,
          subtleText: subtleText,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'State',
          'e.g., CA',
          _stateController,
          cardColor,
          textColor,
          subtleText,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoadingLocation ? null : _useCurrentLocation,
            icon: _isLoadingLocation
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                : Icon(Icons.my_location, color: accent, size: 18),
            label: Text(
              _isLoadingLocation ? 'Detecting location...' : 'Use Current Location',
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: accent, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await _locationService.getCurrentCityAndState();
      
      if (locationData != null && mounted) {
        setState(() {
          _cityController.text = locationData['city'] ?? '';
          _stateController.text = locationData['state'] ?? '';
          _isLoadingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location detected successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not determine your location. Please try again or enter manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        
        String errorMessage = 'Failed to get location. ';
        if (e.toString().contains('permission')) {
          errorMessage += 'Please enable location permissions in app settings.';
        } else if (e.toString().contains('disabled')) {
          errorMessage += 'Please enable location services on your device.';
        } else {
          errorMessage += 'Please try again or enter manually.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildLocationPreference(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Preference',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Local', 'State', 'National'].map((location) {
            final isSelected = _locationPreference == location;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _locationPreference = location),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? accent : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, color: subtleText, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Select the geographical scope for your project. This helps match you with the right creative professionals.',
                style: TextStyle(color: subtleText, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectCategories(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Categories',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCategoryBottomSheet(
            cardColor,
            accent,
            textColor,
            subtleText,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedCategoryName ?? 'Select a category...',
                    style: TextStyle(
                      color: _selectedCategoryName == null
                          ? subtleText
                          : textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: subtleText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Description',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 5,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Describe the project in detail...',
              hintStyle: TextStyle(color: subtleText, fontSize: 14),
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectPlatform(Color cardColor, Color accent, Color textColor) {
    final platforms = [
      {'name': 'Instagram', 'icon': Icons.camera_alt},
      {'name': 'Tiktok', 'icon': Icons.music_note},
      {'name': 'Youtube', 'icon': Icons.play_circle_outline},
      {'name': 'Twitter', 'icon': Icons.chat_bubble_outline},
      {'name': 'Meta', 'icon': Icons.facebook},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Platform',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: platforms.length,
          itemBuilder: (context, index) {
            final platform = platforms[index];
            final isSelected = _selectedPlatforms.contains(platform['name']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPlatforms.remove(platform['name']);
                  } else {
                    _selectedPlatforms.add(platform['name'] as String);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? accent.withOpacity(0.2) : cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? accent : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      platform['icon'] as IconData,
                      color: isSelected ? accent : textColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      platform['name'] as String,
                      style: TextStyle(
                        color: isSelected ? accent : textColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
