// Shows a dismissable banner at the top of the chat when the backend
// is offline or still connecting. Disappears automatically when online.

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../providers/chat_provider.dart';

class BackendStatusBanner extends StatelessWidget {
  final BackendStatus status;
  final VoidCallback onRetry;

  const BackendStatusBanner({
    super.key,
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == BackendStatus.online) return const SizedBox.shrink();

    final isOffline = status == BackendStatus.offline;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        color: isOffline
            ? AppColors.errorContainer
            : AppColors.checking.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
              size: 16,
              color: isOffline ? AppColors.error : AppColors.checking,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOffline
                    ? AppStrings.offlineBannerText
                    : AppStrings.checkingBannerText,
                style: TextStyle(
                  fontSize: 12,
                  color: isOffline ? AppColors.error : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (isOffline) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRetry,
                child: const Text(
                  AppStrings.offlineBannerRetry,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}