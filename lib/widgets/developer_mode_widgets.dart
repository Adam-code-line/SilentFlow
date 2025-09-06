import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// 开发模式浮动按钮 - 仅在开发模式下显示
class DeveloperModeFloatingButton extends StatelessWidget {
  const DeveloperModeFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在开发模式下显示
    if (!AppConfig.isDevelopmentMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.pushNamed(context, '/developer_tools');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.developer_mode,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'DEV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 开发模式指示器 - 显示当前是否在开发模式
class DevelopmentModeIndicator extends StatelessWidget {
  const DevelopmentModeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDevelopmentMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.developer_mode,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            AppConfig.useMockData ? '开发模式 (模拟)' : '开发模式',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 开发模式调试面板 - 显示开发信息的底部面板
class DevelopmentModeDebugPanel extends StatelessWidget {
  final String? currentApi;
  final Map<String, dynamic>? debugInfo;

  const DevelopmentModeDebugPanel({
    super.key,
    this.currentApi,
    this.debugInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDevelopmentMode || !AppConfig.enableDebugLogging) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.orange.withOpacity(0.5)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bug_report,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                '调试信息',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (AppConfig.useMockData)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (currentApi != null) ...[
            const SizedBox(height: 4),
            Text(
              'API: $currentApi',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (debugInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              'Data: ${debugInfo.toString()}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
