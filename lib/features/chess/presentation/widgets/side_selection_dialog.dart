import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/piece.dart';

class SideSelectionDialog extends StatelessWidget {
  const SideSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Your Side',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Who would you like to play as?',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: _SideOption(
                    color: PieceColor.white,
                    label: 'White',
                    onTap: () => Navigator.of(context).pop(PieceColor.white),
                    backgroundColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF5F5F5),
                    textColor: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _SideOption(
                    color: PieceColor.black,
                    label: 'Black',
                    onTap: () => Navigator.of(context).pop(PieceColor.black),
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFF333333),
                    textColor: isDark ? Colors.white70 : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SideOption extends StatelessWidget {
  final PieceColor color;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  const _SideOption({
    required this.color,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the King piece for the respective side
              // const Piece(
              //   type: PieceType.king,
              //   color: PieceColor
              //       .white, // Always use white symbol foundation but color it manually for better control if needed, OR just use the actual color
              // ).render(
              //   fontSize: 56.sp,
              //   color: color == PieceColor.white
              //       ? (Theme.of(context).brightness == Brightness.dark
              //             ? Colors.white
              //             : Colors.black)
              //       : (Theme.of(context).brightness == Brightness.dark
              //             ? Colors.black
              //             : Colors.black),
              // ),
              // Wait, the render method handles color logic specifically for PieceColor.white vs black.
              // Let's rely on the render method's default behavior but pass the Correct PieceColor.
              // HOWEVER, the `render` extension uses specific colors.
              // Let's create a specific Piece instance.
              _buildPieceIcon(context),
              SizedBox(height: 16.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieceIcon(BuildContext context) {
    // We want a clear icon. The render method in extension uses emoji-like text.
    // Let's use that but ensure it contrasts well with the card background.

    // For the White selection card:
    // If Dark Mode: Background is Dark Grey -> White Piece looks good.
    // If Light Mode: Background is Light Grey -> White Piece needs to be Black (outlined) or just standard.

    // For the Black selection card:
    // If Dark Mode: Background is Black -> Black Piece needs white outline or be White colored.
    // If Light Mode: Background is Dark -> Black Piece needs to be White or light grey?

    // Actually, traditionally "White" pieces are light, "Black" pieces are dark.
    // Let's stick to true representation but ensure visible contrast.

    if (color == PieceColor.white) {
      // Representing White side
      // If background is light, we might need a border?
      // The generic render method uses shadows which helps.
      // But let's override for the menu to look stylized.

      // Let's simply force:
      // White Card -> White Piece (with shadow/outline)
      // Black Card -> Black Piece

      // Wait, on a light background, a white piece is invisible.
      // So for the "White" option, we often use an Outline or a "Light" color that is visible.
      // Let's standardise:
      return Text(
        '♔', // White King Symbol
        style: TextStyle(
          fontSize: 60.sp,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      );
    } else {
      // Representing Black side
      return Text(
        '♚', // Black King Symbol
        style: TextStyle(
          fontSize: 60.sp,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.black,
        ),
      );
    }
  }
}
