import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/player.dart';
import '../../domain/models/skill_level.dart';
import '../../domain/validation/player_validator.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import 'skill_selector.dart';

typedef PlayerSubmit = void Function(String name, SkillLevel skill);

/// Bottom sheet to add a new player or edit an existing one.
///
/// It is storage-agnostic: the caller decides what "submit" means.
class PlayerFormSheet extends StatefulWidget {
  const PlayerFormSheet({
    super.key,
    required this.onSubmit,
    required this.isDuplicateName,
    this.initial,
  });

  final Player? initial;
  final PlayerSubmit onSubmit;
  final bool Function(String name) isDuplicateName;

  static Future<void> show(
    BuildContext context, {
    Player? initial,
    required PlayerSubmit onSubmit,
    required bool Function(String name) isDuplicateName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => PlayerFormSheet(
        initial: initial,
        onSubmit: onSubmit,
        isDuplicateName: isDuplicateName,
      ),
    );
  }

  @override
  State<PlayerFormSheet> createState() => _PlayerFormSheetState();
}

class _PlayerFormSheetState extends State<PlayerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _nameFocus = FocusNode();

  SkillLevel? _skill;
  String? _skillError;
  String? _lastAddedName;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name)
      ..addListener(_onNameChanged);
    _skill = widget.initial?.skill;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  void _submit({required bool addAnother}) {
    final nameValid = _formKey.currentState?.validate() ?? false;
    final skillError = _skill == null ? context.l10n.skillErrorMissing : null;
    setState(() => _skillError = skillError);
    if (!nameValid || skillError != null) return;

    final name = PlayerValidator.sanitizeName(_nameController.text);
    widget.onSubmit(name, _skill!);

    if (addAnother) {
      setState(() {
        _lastAddedName = name;
        _skill = null;
        _skillError = null;
      });
      _nameController.clear();
      _nameFocus.requestFocus();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final name = _nameController.text;
    final isDuplicate = name.trim().isNotEmpty && widget.isDuplicateName(name);
    final canAddAnother = !_isEditing;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? l10n.editPlayerTitle : l10n.addPlayerTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing ? l10n.editPlayerSubtitle : l10n.addPlayerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                autofocus: !_isEditing,
                maxLength: AppConstants.maxNameLength,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    PlayerValidator.validateName(value)?.message(l10n),
                onFieldSubmitted: (_) => _nameFocus.unfocus(),
                decoration: InputDecoration(
                  labelText: l10n.playerNameLabel,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  counterText: '',
                  helperText: isDuplicate
                      ? l10n.duplicateNameHelper(name.trim())
                      : null,
                  helperMaxLines: 2,
                  helperStyle: const TextStyle(color: AppColors.warning),
                ),
              ),
              const SizedBox(height: 18),
              Text(l10n.skillLevelLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              SkillSelector(
                selected: _skill,
                errorText: _skillError,
                onChanged: (level) => setState(() {
                  _skill = level;
                  _skillError = null;
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (canAddAnother) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _submit(addAnother: true),
                        child: Text(l10n.saveAndAddNext),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _submit(addAnother: false),
                      child: Text(
                        _isEditing ? l10n.saveChanges : l10n.addPlayerTitle,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _lastAddedName == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.playerAdded(_lastAddedName!),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
