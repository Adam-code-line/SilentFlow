import 'package:flutter/material.dart';

class NoTeamCard extends StatelessWidget {
  const NoTeamCard({super.key});

  static const BoxShadow _cardShadow = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 12,
    spreadRadius: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有加入任何团队',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建或加入一个团队开始协作吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
