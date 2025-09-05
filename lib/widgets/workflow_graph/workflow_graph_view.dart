import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/team_pool_model.dart';

/// 高级工作流图组件
class WorkflowGraphView extends StatefulWidget {
  final TeamPool team;
  final bool isEditable;
  final Function(String)? onTaskTap;

  const WorkflowGraphView({
    super.key,
    required this.team,
    this.isEditable = false,
    this.onTaskTap,
  });

  @override
  State<WorkflowGraphView> createState() => _WorkflowGraphViewState();
}

class _WorkflowGraphViewState extends State<WorkflowGraphView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TransformationController _transformationController =
      TransformationController();

  // 模拟的任务数据
  final List<WorkflowNode> _nodes = [];
  final List<WorkflowEdge> _edges = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _generateMockWorkflow();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _generateMockWorkflow() {
    // 模拟工作流数据生成
    _nodes.addAll([
      WorkflowNode(
        id: '1',
        title: '项目启动',
        status: TaskStatus.completed,
        position: const Offset(100, 100),
        assignee: '张三',
      ),
      WorkflowNode(
        id: '2',
        title: '需求分析',
        status: TaskStatus.completed,
        position: const Offset(100, 200),
        assignee: '李四',
      ),
      WorkflowNode(
        id: '3',
        title: 'UI设计',
        status: TaskStatus.inProgress,
        position: const Offset(300, 150),
        assignee: '王五',
      ),
      WorkflowNode(
        id: '4',
        title: '后端开发',
        status: TaskStatus.inProgress,
        position: const Offset(300, 250),
        assignee: '赵六',
      ),
      WorkflowNode(
        id: '5',
        title: '前端开发',
        status: TaskStatus.pending,
        position: const Offset(500, 200),
        assignee: '钱七',
      ),
      WorkflowNode(
        id: '6',
        title: '测试',
        status: TaskStatus.pending,
        position: const Offset(700, 200),
        assignee: '孙八',
      ),
      WorkflowNode(
        id: '7',
        title: '发布',
        status: TaskStatus.pending,
        position: const Offset(900, 200),
        assignee: '周九',
      ),
    ]);

    _edges.addAll([
      WorkflowEdge(from: '1', to: '2'),
      WorkflowEdge(from: '2', to: '3'),
      WorkflowEdge(from: '2', to: '4'),
      WorkflowEdge(from: '3', to: '5'),
      WorkflowEdge(from: '4', to: '5'),
      WorkflowEdge(from: '5', to: '6'),
      WorkflowEdge(from: '6', to: '7'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildWorkflowGraph(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree,
            color: Colors.indigo[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.team.name} - 工作流图',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  '${_nodes.length} 个任务节点，${_edges.length} 个依赖关系',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildZoomControls(),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Row(
      children: [
        IconButton(
          onPressed: _zoomIn,
          icon: const Icon(Icons.zoom_in),
          iconSize: 20,
          tooltip: '放大',
        ),
        IconButton(
          onPressed: _zoomOut,
          icon: const Icon(Icons.zoom_out),
          iconSize: 20,
          tooltip: '缩小',
        ),
        IconButton(
          onPressed: _resetZoom,
          icon: const Icon(Icons.center_focus_strong),
          iconSize: 20,
          tooltip: '重置视图',
        ),
      ],
    );
  }

  Widget _buildWorkflowGraph() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(50),
            minScale: 0.3,
            maxScale: 3.0,
            child: Container(
              width: 1200,
              height: 600,
              child: CustomPaint(
                painter: WorkflowPainter(
                  nodes: _nodes,
                  edges: _edges,
                  animationValue: _fadeAnimation.value,
                ),
                child: Stack(
                  children:
                      _nodes.map((node) => _buildNodeWidget(node)).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNodeWidget(WorkflowNode node) {
    return Positioned(
      left: node.position.dx - 60,
      top: node.position.dy - 30,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 800 + (_nodes.indexOf(node) * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: GestureDetector(
              onTap: () => _handleNodeTap(node),
              child: Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(node.status),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(node.status).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _getStatusColor(node.status).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      node.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.assignee,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildLegendItem(TaskStatus.completed, '已完成'),
          const SizedBox(width: 16),
          _buildLegendItem(TaskStatus.inProgress, '进行中'),
          const SizedBox(width: 16),
          _buildLegendItem(TaskStatus.pending, '待处理'),
          const SizedBox(width: 16),
          _buildLegendItem(TaskStatus.blocked, '受阻'),
          const Spacer(),
          Text(
            '双击节点查看详情 • 拖拽缩放查看全局',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(TaskStatus status, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFF6AD55);
      case TaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case TaskStatus.completed:
        return const Color(0xFF48BB78);
      case TaskStatus.blocked:
        return const Color(0xFFF56565);
    }
  }

  void _handleNodeTap(WorkflowNode node) {
    if (widget.onTaskTap != null) {
      widget.onTaskTap!(node.id);
    } else {
      _showNodeDetails(node);
    }
  }

  void _showNodeDetails(WorkflowNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(node.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态: ${_getStatusText(node.status)}'),
            Text('负责人: ${node.assignee}'),
            const SizedBox(height: 16),
            Text(
              '任务详情：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('这里是任务的详细描述信息...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (widget.isEditable)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editNode(node);
              },
              child: const Text('编辑'),
            ),
        ],
      ),
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.blocked:
        return '受阻';
    }
  }

  void _editNode(WorkflowNode node) {
    // TODO: 实现节点编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑功能开发中...')),
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 3.0) {
      _transformationController.value *= Matrix4.identity()..scale(1.2);
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.3) {
      _transformationController.value *= Matrix4.identity()..scale(0.8);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}

/// 工作流节点数据模型
class WorkflowNode {
  final String id;
  final String title;
  final TaskStatus status;
  final Offset position;
  final String assignee;

  WorkflowNode({
    required this.id,
    required this.title,
    required this.status,
    required this.position,
    required this.assignee,
  });
}

/// 工作流边数据模型
class WorkflowEdge {
  final String from;
  final String to;

  WorkflowEdge({
    required this.from,
    required this.to,
  });
}

/// 任务状态枚举
enum TaskStatus {
  pending,
  inProgress,
  completed,
  blocked,
}

/// 自定义画布绘制工作流图
class WorkflowPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final double animationValue;

  WorkflowPainter({
    required this.nodes,
    required this.edges,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制连接线
    final linePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;

    for (final edge in edges) {
      final fromNode = nodes.firstWhere((node) => node.id == edge.from);
      final toNode = nodes.firstWhere((node) => node.id == edge.to);

      final start = fromNode.position;
      final end = toNode.position;

      // 绘制连接线
      final animatedEnd = Offset.lerp(start, end, animationValue)!;
      canvas.drawLine(start, animatedEnd, linePaint);

      // 绘制箭头
      if (animationValue > 0.7) {
        _drawArrow(canvas, start, animatedEnd, arrowPaint);
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 8.0;
    final direction = (end - start).direction;
    final arrowP1 =
        end + Offset.fromDirection(direction + math.pi * 0.8, arrowSize);
    final arrowP2 =
        end + Offset.fromDirection(direction - math.pi * 0.8, arrowSize);

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
