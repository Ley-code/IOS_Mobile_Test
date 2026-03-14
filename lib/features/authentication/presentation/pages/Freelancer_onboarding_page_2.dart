import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart'
    as domain;
import '../widgets/selectable_widget.dart';
import '../widgets/language_widget.dart';

class FreelancerOnboardingPage2 extends StatefulWidget {
  final double progressValue;
  final String stepLabel;

  final Map<String, dynamic>? partialData;

  const FreelancerOnboardingPage2({
    this.partialData,
    this.selectedRole,
    super.key,
    this.progressValue = 0.50,
    this.stepLabel = '2/4',
  });

  final domain.UserRole?
  selectedRole; // kept for compatibility but data comes in partialData
  @override
  State<FreelancerOnboardingPage2> createState() =>
      _ContentCreatorPageSkillsState();
}

class _ContentCreatorPageSkillsState extends State<FreelancerOnboardingPage2> {
  final List<String> _specialities = [
    'Graphic Design',
    'Social Media Marketing',
    'Content Creation',
    'Video Production',
    'Copywriting',
    'Illustration',
    'Photography',
    'Animation',
  ];

  // selection state
  final Set<String> _selectedSpecialities = <String>{};
  // languages state
  final List<LanguageEntry> _languages = [
    LanguageEntry(language: 'English', level: 'Native'),
    LanguageEntry(language: 'French', level: 'Intermediate'),
  ];

  // helper to show add/edit modal sheet
  void _showAddEditLanguageSheet({LanguageEntry? entry}) {
    final bool isEdit = entry != null;
    final TextEditingController langCtrl = TextEditingController(
      text: entry?.language ?? '',
    );
    String level = entry?.level ?? 'Native';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F1A2B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    isEdit ? 'Edit language' : 'Add language',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: langCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Language',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Level', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFF0B1220),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Native', child: Text('Native')),
                      DropdownMenuItem(
                        value: 'Beginner',
                        child: Text('Beginner'),
                      ),
                      DropdownMenuItem(
                        value: 'Intermediate',
                        child: Text('Intermediate'),
                      ),
                      DropdownMenuItem(
                        value: 'Advanced',
                        child: Text('Advanced'),
                      ),
                    ],
                    onChanged: (v) => level = v ?? level,
                    dropdownColor: const Color(0xFF0F1A2B),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final String lang = langCtrl.text.trim();
                            if (lang.isEmpty) return; // simple validation
                            setState(() {
                              if (isEdit) {
                                entry.language = lang;
                                entry.level = level;
                              } else {
                                _languages.add(
                                  LanguageEntry(language: lang, level: level),
                                );
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A6FF),
                          ),
                          child: Text(isEdit ? 'Save' : 'Add'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isEdit)
                        OutlinedButton(
                          onPressed: () {
                            setState(() => _languages.remove(entry));
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Pinned top row: back icon + progress bar + step indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: widget.progressValue,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.stepLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Divider
            const SizedBox(height: 8),

            // Scrollable content below the pinned header
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white12,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/freelancer_icon.png',
                                      width: 36,
                                      height: 36,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Define Your Expertise',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select your skills',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        "What's your Speciality?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'select one or more categories, that best describes your work',
                        style: TextStyle(color: Colors.white54),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _specialities.map((s) {
                          final selected = _selectedSpecialities.contains(s);
                          return SelectableWidget(
                            label: s,
                            selected: selected,
                            selectedColor: accent,
                            backgroundColor: Colors.white10,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedSpecialities.remove(s);
                                } else {
                                  _selectedSpecialities.add(s);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'What Languages do you speak?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Example language boxes (now dynamic)
                      Column(
                        children: _languages
                            .map(
                              (e) => LanguageTile(
                                entry: e,
                                onEdit: () =>
                                    _showAddEditLanguageSheet(entry: e),
                                onDelete: () {
                                  setState(() => _languages.remove(e));
                                },
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showAddEditLanguageSheet(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '+ Add Language',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Continue button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedSpecialities.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select at least one speciality',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (widget.partialData == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error: Missing registration data',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Combine languages into string list
                            final languagesList = _languages
                                .map((e) => '${e.language}:${e.level}')
                                .toList();

                            final entity = FreelancerSignupEntity(
                              firstName: widget.partialData!['firstName'],
                              lastName: widget.partialData!['lastName'],
                              email: widget.partialData!['email'],
                              phoneNumber: widget.partialData!['phoneNumber'],
                              password: widget.partialData!['password'],
                              about: widget.partialData!['about'],
                              selectedRole:
                                  widget.partialData!['selectedRole']
                                      as domain.UserRole,
                              preferredLanguage:
                                  widget.partialData!['preferredLanguage'],
                              socialMediaLinks:
                                  widget.partialData!['socialMediaLinks'],
                              specialities: _selectedSpecialities.toList(),
                              languages: languagesList,
                            );

                            // Check if user is a content creator
                            if (entity.selectedRole ==
                                domain.UserRole.contentCreator) {
                              // Navigate to social media page for content creators
                              Navigator.pushNamed(
                                context,
                                '/content_creator_page_socialmedia',
                                arguments: entity,
                              );
                            } else {
                              // Skip social media page for other roles
                              Navigator.pushNamed(
                                context,
                                '/terms_and_conditions_page',
                                arguments: entity,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
