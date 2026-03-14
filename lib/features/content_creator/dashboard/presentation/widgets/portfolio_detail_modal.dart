import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_event.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PortfolioDetailModal extends StatefulWidget {
  final PortfolioItemEntity item;
  final bool isEditable;

  const PortfolioDetailModal({
    super.key,
    required this.item,
    required this.isEditable,
  });

  @override
  State<PortfolioDetailModal> createState() => _PortfolioDetailModalState();
}

class _PortfolioDetailModalState extends State<PortfolioDetailModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _linkController;
  late String _selectedType;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descController = TextEditingController(text: widget.item.description);
    _linkController = TextEditingController(text: widget.item.link ?? '');
    _selectedType = widget.item.type.toLowerCase();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _onDelete() {
    if (widget.item.id == null || widget.item.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: Portfolio item ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Portfolio Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.read<InfluencerDashboardBloc>().add(
                DeletePortfolioItemEvent(widget.item.id!),
              );
              Navigator.pop(context); // Close modal
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    if (widget.item.id == null || widget.item.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: Portfolio item ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedItem = PortfolioItemEntity(
      id: widget.item.id,
      title: _titleController.text,
      description: _descController.text,
      type: _selectedType,
      link: _linkController.text.isEmpty ? null : _linkController.text,
    );

    context.read<InfluencerDashboardBloc>().add(
      UpdatePortfolioItemEvent(updatedItem),
    );

    setState(() => _isEditing = false);
    // The Bloc will refresh the data and ideally the modal would close or refresh
    // For now, let's close it after a short delay or just stay there
    Navigator.pop(context);
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
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Work' : 'Work Details',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.isEditable)
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                setState(() => _isEditing = !_isEditing),
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit,
                              color: accent,
                            ),
                          ),
                          IconButton(
                            onPressed: _onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: textColor),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!_isEditing) ...[
                  if (widget.item.link != null && widget.item.link!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: widget.item.link!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: cardColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: cardColor,
                          child: Icon(Icons.error, color: accent),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.item.type,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      color: subtleText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  _buildTextField(
                    label: 'Title',
                    controller: _titleController,
                    hint: 'E.g. Summer Campaign',
                    textColor: textColor,
                    subtleText: subtleText,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    controller: _descController,
                    hint: 'Describe your work...',
                    textColor: textColor,
                    subtleText: subtleText,
                    cardColor: cardColor,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTypeSelector(
                    selectedType: _selectedType,
                    onTypeSelected: (type) =>
                        setState(() => _selectedType = type),
                    cardColor: cardColor,
                    accent: accent,
                    textColor: textColor,
                    subtleText: subtleText,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'External Link',
                    controller: _linkController,
                    hint: 'https://...',
                    textColor: textColor,
                    subtleText: subtleText,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onSave,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
}
