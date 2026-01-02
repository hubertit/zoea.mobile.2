import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Refer & Earn',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 32, color: context.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(),
            const SizedBox(height: 32),
            
            // Referral Code Section
            _buildReferralCodeSection(),
            const SizedBox(height: 32),
            
            // How it Works Section
            _buildHowItWorksSection(),
            const SizedBox(height: 32),
            
            // Rewards Section
            _buildRewardsSection(),
            const SizedBox(height: 32),
            
            // Referral Stats
            _buildReferralStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColorTheme.withOpacity(0.1),
            context.primaryColorTheme.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primaryColorTheme.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: context.primaryColorTheme,
          ),
          const SizedBox(height: 16),
          Text(
            'Invite Friends & Earn Rewards',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Share your referral code and earn rewards for every friend who joins Zoea',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Referral Code',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.grey200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZOEAFRIEND',
                      style: context.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share this code with your friends',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Referral code copied to clipboard',
                        style: context.bodyMedium.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                      backgroundColor: context.cardColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.copy, color: context.primaryTextColor),
                style: IconButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryColor
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              const referralCode = 'ZOEAFRIEND';
              const shareText = 'Join me on Zoea Africa and discover amazing places in Rwanda! Use my referral code: $referralCode to get started!';
              const shareUrl = 'https://zoea.africa?ref=$referralCode';
              
              await SharePlus.instance.share(ShareParams(text: '$shareText\n$shareUrl'));
            },
            icon: Icon(Icons.share, color: context.primaryTextColor),
            label: Text(
              'Share Referral Code',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColorTheme,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryColor
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it Works',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          step: '1',
          title: 'Share Your Code',
          description: 'Send your referral code to friends via social media, email, or text',
          icon: Icons.share,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          step: '2',
          title: 'Friend Signs Up',
          description: 'Your friend uses your code when creating their Zoea account',
          icon: Icons.person_add,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          step: '3',
          title: 'Earn Rewards',
          description: 'You both get rewards when they complete their first booking',
          icon: Icons.card_giftcard,
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryColorTheme,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            icon,
            color: context.primaryColorTheme,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRewardCard(
                title: 'For You',
                amount: '500',
                currency: 'RWF',
                description: 'When friend joins',
                color: context.primaryColorTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                title: 'For Friend',
                amount: '300',
                currency: 'RWF',
                description: 'Welcome bonus',
                color: context.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String amount,
    required String currency,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$amount $currency',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.bodySmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Referrals',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.grey200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Total Referrals',
                value: '12',
                icon: Icons.people,
              ),
              Container(
                width: 1,
                height: 40,
                color: context.grey300,
              ),
              _buildStatItem(
                label: 'Earned Rewards',
                value: '6,000 RWF',
                icon: Icons.monetization_on,
              ),
              Container(
                width: 1,
                height: 40,
                color: context.grey300,
              ),
              _buildStatItem(
                label: 'Pending',
                value: '3',
                icon: Icons.schedule,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: context.primaryColorTheme,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.bodySmall.copyWith(
            color: context.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
