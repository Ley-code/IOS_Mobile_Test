import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_event.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_state.dart';

class AddWorkPage extends StatefulWidget {
  const AddWorkPage({super.key});

  @override
  State<AddWorkPage> createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _selectedType = 'image';
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return BlocListener<InfluencerDashboardBloc, InfluencerDashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is DashboardLoaded) {
          // Portfolio was added successfully, navigate back
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          title: Text('Add Work', style: TextStyle(color: textColor)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _uploadArea(accent, textColor, subtleText, cardColor),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Title',
                controller: _titleController,
                hint: 'E.g. Summer Campaign Photoshoot',
                textColor: textColor,
                subtleText: subtleText,
                cardColor: cardColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Description',
                controller: _descController,
                hint: 'Describe what you did...',
                textColor: textColor,
                subtleText: subtleText,
                cardColor: cardColor,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTypeSelector(
                selectedType: _selectedType,
                onTypeSelected: (type) => setState(() => _selectedType = type),
                cardColor: cardColor,
                accent: accent,
                textColor: textColor,
                subtleText: subtleText,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'External Link (Optional)',
                controller: _linkController,
                hint: 'https://...',
                textColor: textColor,
                subtleText: subtleText,
                cardColor: cardColor,
              ),
              const SizedBox(height: 32),
              BlocBuilder<InfluencerDashboardBloc, InfluencerDashboardState>(
                builder: (context, state) {
                  final isLoading = state is DashboardLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : _uploadWork,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Upload Work',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadWork() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final portfolioItem = PortfolioItemEntity(
      title: _titleController.text,
      description: _descController.text,
      type: _selectedType,
      link: _linkController.text.isEmpty ? null : _linkController.text,
    );

    context.read<InfluencerDashboardBloc>().add(
      AddPortfolioItemEvent(portfolioItem, coverImage: _selectedImage),
    );
  }

  Widget _uploadArea(
    Color accent,
    Color textColor,
    Color subtleText,
    Color cardColor,
  ) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImage != null
                ? accent
                : subtleText.withOpacity(0.3),
            width: _selectedImage != null ? 2 : 1,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: accent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Change Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: accent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Cover Image',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select from gallery',
                    style: TextStyle(color: subtleText, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTypeSelector({
    required String selectedType,
    required Function(String) onTypeSelected,
    required Color cardColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
  }) {
    final types = [
      {'value': 'image', 'label': 'Images', 'icon': Icons.image},
      {'value': 'video', 'label': 'Videos', 'icon': Icons.videocam},
      {'value': 'audio', 'label': 'Audio', 'icon': Icons.audiotrack},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final isSelected = selectedType == type['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTypeSelected(type['value'] as String),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected ? Colors.white : textColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color textColor,
    required Color subtleText,
    required Color cardColor,
    int maxLines = 1,
  }) {
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: subtleText.withOpacity(0.5)),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
