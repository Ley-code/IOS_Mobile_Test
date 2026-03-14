import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/services/place_autocomplete_service.dart';

/// A reusable city autocomplete field widget
/// 
/// Provides autocomplete suggestions as user types
/// Automatically extracts and populates state when city is selected
class CityAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final Color cardColor;
  final Color textColor;
  final Color subtleText;
  final Function(String city, String? state)? onCitySelected;

  const CityAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.cityController,
    required this.stateController,
    required this.cardColor,
    required this.textColor,
    required this.subtleText,
    this.onCitySelected,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final PlaceAutocompleteService _autocompleteService = PlaceAutocompleteService();
  final FocusNode _focusNode = FocusNode();
  
  List<PlaceResult> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay hiding suggestions to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(value);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      final results = await _autocompleteService.searchPlaces(query);
      
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
        _showOverlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _suggestions = [];
        });
      }
    }
  }

  void _onSuggestionSelected(PlaceResult place) {
    widget.cityController.text = place.city;
    if (place.state != null) {
      widget.stateController.text = place.state!;
    }
    
    if (widget.onCitySelected != null) {
      widget.onCitySelected!(place.city, place.state);
    }

    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    
    _focusNode.unfocus();
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    
    if (!_showSuggestions || _suggestions.isEmpty) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          color: widget.cardColor,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: widget.textColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final place = _suggestions[index];
                      return InkWell(
                        onTap: () => _onSuggestionSelected(place),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: widget.subtleText.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: widget.subtleText,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  place.displayName,
                                  style: TextStyle(
                                    color: widget.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: widget.cityController,
            focusNode: _focusNode,
            style: TextStyle(color: widget.textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: widget.subtleText, fontSize: 14),
              border: InputBorder.none,
              isCollapsed: true,
              suffixIcon: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.subtleText,
                        ),
                      ),
                    )
                  : null,
            ),
            onChanged: _onTextChanged,
          ),
        ),
      ],
    );
  }
}
