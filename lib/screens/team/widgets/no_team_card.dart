import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NoTeamCard extends StatefulWidget {
  const NoTeamCard({
    super.key,
  });

  @override
  State<NoTeamCard> createState() => _NoTeamCardState();
}

class _NoTeamCardState extends State<NoTeamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static const BoxShadow _cardShadow = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 12,
    spreadRadius: 0,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // 高级渐变背景
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.grey[50]!.withOpacity(0.9),
                    Colors.grey[100]!.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  _cardShadow,
                  // 额外的内阴影效果
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(-1, -1),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
                // 玻璃态边框
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // 动画图标区域
                  _buildAnimatedIcon(),
                  const SizedBox(height: 20),
                  // 主标题 - 带Shimmer效果
                  Shimmer.fromColors(
                    baseColor: Colors.grey[600]!,
                    highlightColor: Colors.grey[400]!,
                    period: const Duration(seconds: 2),
                    child: AutoSizeText(
                      '还没有加入任何团队',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      minFontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 副标题
                  AutoSizeText(
                    '创建或加入一个团队开始协作吧！',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 12,
                  ),
                  const SizedBox(height: 16),
                  // 提示指示器
                  _buildPulsingIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[100]!.withOpacity(0.3),
            Colors.purple[100]!.withOpacity(0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_animationController.value * 0.1),
            child: Transform.rotate(
              angle: _animationController.value * 0.2,
              child: Icon(
                Icons.groups_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulsingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.purple.withOpacity(0.5),
                Colors.blue.withOpacity(0.3),
              ],
              stops: [
                0.0,
                _animationController.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
