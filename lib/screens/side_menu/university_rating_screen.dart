import 'package:education/core/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/bloc/app_cubit.dart';
import '../../services/application_api_service.dart';
import '../../services/snackbar_service.dart';
import '../../services/student_api_service.dart';
import '../../utils/auth_utils.dart';
import '../../widgets/common_widgets.dart';
import 'side_menu_common.dart';

class UniversityRatingScreen extends StatefulWidget {
  const UniversityRatingScreen({
    super.key,
    this.universityId,
    this.universityName,
  });

  final String? universityId;
  final String? universityName;

  @override
  State<UniversityRatingScreen> createState() => _UniversityRatingScreenState();
}

class _UniversityOption {
  const _UniversityOption({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logoPath,
  });

  final String id;
  final String name;
  final String nameAr;
  final String logoPath;
}

class _UniversityRatingScreenState extends State<UniversityRatingScreen>
    with CubitStateMixin<UniversityRatingScreen> {
  final ApplicationApiService _applicationApi = const ApplicationApiService();
  final StudentApiService _studentApi = const StudentApiService();
  final TextEditingController _remarkController = TextEditingController();

  bool _isLoadingUniversities = true;
  bool _isSubmitting = false;
  double _rating = 4.0;

  List<_UniversityOption> _universities = <_UniversityOption>[];
  _UniversityOption? _selectedUniversity;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    updateView(() => _isLoadingUniversities = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty) {
        if (!mounted) return;
        updateView(() {
          _universities = <_UniversityOption>[];
          _isLoadingUniversities = false;
        });
        return;
      }

      final Map<String, dynamic> overview = await _applicationApi.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      final Object? applications = overview['applications'];
      final Map<String, _UniversityOption> uniqueUniversities =
          <String, _UniversityOption>{};

      if (applications is List) {
        for (final Object? item in applications) {
          if (item is! Map) continue;

          final Map<String, dynamic> application = Map<String, dynamic>.from(item);
          final Map<String, dynamic> university =
              Map<String, dynamic>.from(application['university'] ?? <String, dynamic>{});

          final String id = (university['id'] ?? '').toString().trim();
          if (id.isEmpty) continue;

          uniqueUniversities[id] = _UniversityOption(
            id: id,
            name: (university['name'] ?? '').toString().trim(),
            nameAr: (university['nameAr'] ?? '').toString().trim(),
            logoPath: (university['logoPath'] ?? '').toString().trim(),
          );
        }
      }

      if (!mounted) return;

      final List<_UniversityOption> loaded =
          uniqueUniversities.values.toList(growable: false);

      _UniversityOption? initialSelection;
      final String presetId = widget.universityId?.trim() ?? '';
      if (presetId.isNotEmpty) {
        final _UniversityOption presetOption = loaded.firstWhere(
          (item) => item.id == presetId,
          orElse: () => _UniversityOption(
            id: presetId,
            name: widget.universityName?.trim() ?? '',
            nameAr: '',
            logoPath: '',
          ),
        );

        if (!loaded.any((item) => item.id == presetId)) {
          loaded.insert(0, presetOption);
        }
        initialSelection = presetOption;
      } else if (loaded.isNotEmpty) {
        initialSelection = loaded.first;
      }

      updateView(() {
        _universities = loaded;
        _selectedUniversity = initialSelection;
        _isLoadingUniversities = false;
      });
    } on ApplicationApiException catch (error) {
      if (!mounted) return;

      if (isStudentNotFoundError(error)) {
        await performLogout(context);
        return;
      }

      updateView(() {
        _universities = <_UniversityOption>[];
        _isLoadingUniversities = false;
      });
    } catch (_) {
      if (!mounted) return;
      updateView(() {
        _universities = <_UniversityOption>[];
        _isLoadingUniversities = false;
      });
    }
  }

  String _localizedUniversityName(BuildContext context, _UniversityOption option) {
    if (context.l10n.textDirection == TextDirection.rtl &&
        option.nameAr.trim().isNotEmpty) {
      return option.nameAr;
    }
    return option.name.trim().isNotEmpty
        ? option.name
        : context.l10n.text('university');
  }

  Widget _buildUniversityLabel(
    BuildContext context,
    _UniversityOption option, {
    bool shrinkWrap = false,
  }) {
    final String label = _localizedUniversityName(context, option);

    if (option.logoPath.isEmpty) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            ImageUrlHelper.resolveUploadUrl(option.logoPath),
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 24,
              height: 24,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    final _UniversityOption? selected = _selectedUniversity;
    if (selected == null || selected.id.trim().isEmpty) {
      snackBarService.showError(
        message: context.l10n.text('pleaseSelectUniversity'),
      );
      return;
    }

    final String remark = _remarkController.text.trim();
    if (remark.isEmpty) {
      snackBarService.showError(
        message: context.l10n.text('pleaseEnterRemark'),
      );
      return;
    }

    updateView(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> response = await _studentApi.submitUniversityRating(
        universityId: selected.id,
        rating: _rating,
        remark: remark,
      );

      if (!mounted) return;

      snackBarService.showSuccess(
        message: response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString()
            : context.l10n.text('ratingUpdatedSuccessfully'),
      );
    } on StudentApiException catch (error) {
      if (!mounted) return;
      snackBarService.showError(
        message: error.message.isNotEmpty
            ? error.message
            : context.l10n.text('failedSubmitRating'),
      );
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedSubmitRating'),
      );
    } finally {
      if (mounted) {
        updateView(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildUniversityDropdown(BuildContext context) {
    if (_isLoadingUniversities) {
      return InputDecorator(
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.text('selectUniversity'),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_universities.isEmpty) {
      return Text(
        context.l10n.text('noApplicationsAvailable'),
        style: const TextStyle(color: AppColors.textMuted),
      );
    }

    return DropdownButtonFormField<_UniversityOption>(
      value: _selectedUniversity,
      isExpanded: true,
      decoration: _fieldDecoration(),
      selectedItemBuilder: (context) {
        return _universities
            .map(
              (option) => _buildUniversityLabel(
                context,
                option,
              ),
            )
            .toList(growable: false);
      },
      items: _universities
          .map(
            (option) => DropdownMenuItem<_UniversityOption>(
              value: option,
              child: _buildUniversityLabel(
                context,
                option,
                shrinkWrap: true,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: _isSubmitting
          ? null
          : (value) {
              updateView(() {
                _selectedUniversity = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('universityRating'),
      child: buildCubitView(
        (context) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: context.l10n.text('selectUniversity'),
                    child: _buildUniversityDropdown(context),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: context.l10n.text('yourRating'),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(5, (index) {
                            final int starValue = index + 1;
                            final bool isFull = _rating >= starValue;
                            final bool isHalf =
                                !isFull && _rating >= starValue - 0.5;

                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      updateView(() {
                                        _rating = starValue.toDouble();
                                      });
                                    },
                              onLongPress: _isSubmitting
                                  ? null
                                  : () {
                                      updateView(() {
                                        _rating = starValue - 0.5;
                                      });
                                    },
                              icon: Icon(
                                isFull
                                    ? Icons.star_rounded
                                    : isHalf
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded,
                                color: AppColors.accent,
                                size: 32,
                              ),
                            );
                          }),
                        ),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: context.l10n.text('writeRemark'),
                    child: TextField(
                      controller: _remarkController,
                      enabled: !_isSubmitting,
                      maxLines: 4,
                      decoration: _fieldDecoration(
                        hintText: context.l10n.text('writeRemark'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    label: context.l10n.text('submitRating'),
                    onPressed: _isSubmitting ? null : _submitRating,
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      );
    },
  ),
);
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFFFFAF5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE6DFD7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE6DFD7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
