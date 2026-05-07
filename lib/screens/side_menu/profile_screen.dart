import 'package:education/core/app_localizations.dart';
import 'package:education/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart' show AppPrimaryButton;
import 'side_menu_common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenuScaffold(title: 'My Profile', child: ProfileBody());
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 6),
        ProfileAvatar(),
        SizedBox(height: 18),
        ProfileSectionTitle('Basic Information'),
        SizedBox(height: 10),
        ProfileLabel('Full Name'),
        ProfileInput(hint: 'Full Name', icon: Icons.person_outline_rounded),
        SizedBox(height: 12),
        ProfileLabel('Gender'),
        GenderSelector(),
        SizedBox(height: 14),
        ProfileLabel('Date of Birth'),
        ProfileInput(
          hint: 'DD/MM/YYYY',
          icon: Icons.calendar_month_outlined,
          trailing: Icons.calendar_today_outlined,
        ),
        SizedBox(height: 12),
        ProfileLabel('Nationality'),
        ProfileInput(
          hint: 'Nationality',
          icon: Icons.language_outlined,
          trailing: Icons.keyboard_arrow_down_rounded,
        ),
        SizedBox(height: 12),
        ProfileLabel('Country of Residence'),
        ProfileInput(
          hint: 'Arab',
          icon: Icons.public_outlined,
          trailing: Icons.keyboard_arrow_down_rounded,
        ),
        SizedBox(height: 12),
        ProfileLabel('Mobile Number'),
        ProfileInput(
          hint: 'Mobile Number',
          icon: Icons.call_outlined,
          trailing: Icons.check_circle_outline_rounded,
        ),
        SizedBox(height: 12),
        ProfileLabel('Email Address'),
        ProfileInput(
          hint: 'Email Address',
          icon: Icons.mail_outline_rounded,
          trailing: Icons.check_circle_outline_rounded,
        ),
        SizedBox(height: 18),
        ProfileSectionTitle('Address Information'),
        SizedBox(height: 10),
        ProfileLabel('Address'),
        ProfileInput(
          hint: 'Address',
          icon: Icons.location_on_outlined,
          multiLine: true,
        ),
        SizedBox(height: 18),
        ProfileSectionTitle('Emergency Contact'),
        SizedBox(height: 10),
        ProfileLabel('Guardian Name'),
        ProfileInput(hint: 'Guardian Name', icon: Icons.person_outline_rounded),
        SizedBox(height: 12),
        ProfileLabel('Relationship'),
        ProfileInput(hint: 'Relationship', icon: Icons.person_outline_rounded),
        SizedBox(height: 12),
        ProfileLabel('Mobile Number'),
        ProfileInput(
          hint: 'Mobile Number',
          icon: Icons.call_outlined,
          trailing: Icons.check_circle_outline_rounded,
        ),
        SizedBox(height: 12),
        ProfileLabel('Email Address'),
        ProfileInput(
          hint: 'Email Address',
          icon: Icons.mail_outline_rounded,
          trailing: Icons.check_circle_outline_rounded,
        ),
        SizedBox(height: 22),
        SaveButton(),
        SizedBox(height: 22),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 3),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 15,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800),
    );
  }
}

class ProfileLabel extends StatelessWidget {
  const ProfileLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ProfileInput extends StatelessWidget {
  const ProfileInput({
    super.key,
    required this.hint,
    required this.icon,
    this.trailing,
    this.multiLine = false,
  });

  final String hint;
  final IconData icon;
  final IconData? trailing;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: multiLine ? 88 : 52),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD7D5D3)),
      ),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: multiLine ? 12 : 0),
            child: Icon(icon, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: multiLine ? 12 : 0),
              child: Text(
                hint,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          if (trailing != null)
            Icon(trailing, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        GenderOption(label: 'Male', selected: true),
        SizedBox(width: 22),
        GenderOption(label: 'Female', selected: false),
      ],
    );
  }
}

class GenderOption extends StatelessWidget {
  const GenderOption({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.textMuted,
              width: 1.2,
            ),
          ),
          child: selected
              ? Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: context.l10n.text('save'),
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const HomeScreen())),
    );
  }
}
