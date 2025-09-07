import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/team_pool_model.dart';
import '../../providers/enhanced_workflow_provider.dart';
import 'components/workflow_canvas.dart';
import 'components/task_node_widget.dart';
import 'components/task_dialogs.dart';

/// 增强版工作流图组件 - 支持交互、拖拽、编辑等高级功能
class EnhancedWorkflowView extends StatefulWidget {
  final TeamPool team;
  final bool isEditable;
  final Function(String taskId)? onTaskTap;

  const EnhancedWorkflowView({
    super.key,
    required this.team,
    this.isEditable = false,
    this.onTaskTap,
  });

  @override
  State<EnhancedWorkflowView> createState() => _EnhancedWorkflowViewState();
}

class _EnhancedWorkflowViewState extends State<EnhancedWorkflowView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  String? _hoveredTaskId;
  String? _selectedTaskId;
  bool _showConnectionMode = false;
  String? _connectionFromTaskId;

  // 筛选状态
  Set<EnhancedTaskStatus> _statusFilter = {};
  Set<EnhancedTaskPriority> _priorityFilter = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 初始化Provider数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EnhancedWorkflowProvider>()
          .initializeTeamTasks(widget.team.id);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnhancedWorkflowProvider(),
      child: Consumer<EnhancedWorkflowProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnhancedHeader(provider),
                const SizedBox(height: 20),
                _buildToolbar(provider),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildInteractiveWorkflowGraph(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeader(EnhancedWorkflowProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Flex(
          direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: isSmallScreen
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isSmallScreen
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: isSmallScreen
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.team.name} - 工作流图',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                  textAlign: isSmallScreen ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  '共 ${provider.filteredTasks.length} 个任务 • ${provider.completedTasksCount}/${provider.totalTasksCount} 已完成',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (isSmallScreen) const SizedBox(height: 16),
            _buildActionButtons(provider, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(
      EnhancedWorkflowProvider provider, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showConnectionMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 4),
                Text(
                  '连接模式',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (_showConnectionMode) const SizedBox(width: 8),
        if (widget.isEditable) ...[
          IconButton(
            onPressed: () => _toggleConnectionMode(),
            icon: Icon(
              _showConnectionMode ? Icons.link_off : Icons.link,
              size: isSmallScreen ? 20 : 24,
            ),
            tooltip: _showConnectionMode ? '退出连接模式' : '设置任务依赖',
            style: IconButton.styleFrom(
              backgroundColor:
                  _showConnectionMode ? Colors.blue[100] : Colors.grey[100],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(provider),
            icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
            label: Text(
              '添加任务',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C51BF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildTemplateSelector(provider),
        ],
      ],
    );
  }

  Widget _buildTemplateSelector(EnhancedWorkflowProvider provider) {
    return PopupMenuButton<String>(
      tooltip: '自动生成连线',
      onSelected: (template) => _applyConnectionTemplate(template, provider),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'linear',
          child: Row(
            children: [
              Icon(Icons.trending_flat, size: 16),
              SizedBox(width: 8),
              Text('线性流程'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'parallel',
          child: Row(
            children: [
              Icon(Icons.call_split, size: 16),
              SizedBox(width: 8),
              Text('并行流程'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'complex',
          child: Row(
            children: [
              Icon(Icons.account_tree, size: 16),
              SizedBox(width: 8),
              Text('复杂流程'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.clear_all, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('清除连线', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_graph, size: 16),
            SizedBox(width: 4),
            Text('模板', style: TextStyle(fontSize: 12)),
            Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(EnhancedWorkflowProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 状态筛选
          _buildFilterChip(
            label: '进行中',
            isSelected: _statusFilter.contains(EnhancedTaskStatus.inProgress),
            color: Colors.blue,
            onTap: () =>
                _toggleStatusFilter(EnhancedTaskStatus.inProgress, provider),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '已完成',
            isSelected: _statusFilter.contains(EnhancedTaskStatus.completed),
            color: Colors.green,
            onTap: () =>
                _toggleStatusFilter(EnhancedTaskStatus.completed, provider),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '待开始',
            isSelected: _statusFilter.contains(EnhancedTaskStatus.pending),
            color: Colors.orange,
            onTap: () =>
                _toggleStatusFilter(EnhancedTaskStatus.pending, provider),
          ),
          const SizedBox(width: 16),
          // 优先级筛选
          _buildFilterChip(
            label: '高优先级',
            isSelected: _priorityFilter.contains(EnhancedTaskPriority.high),
            color: Colors.red,
            onTap: () =>
                _togglePriorityFilter(EnhancedTaskPriority.high, provider),
          ),
          const SizedBox(width: 8),
          // 清除筛选
          if (_statusFilter.isNotEmpty || _priorityFilter.isNotEmpty)
            TextButton.icon(
              onPressed: () => _clearFilters(provider),
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('清除筛选'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color.withOpacity(0.8) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveWorkflowGraph(EnhancedWorkflowProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return WorkflowCanvas(
          tasks: provider.filteredTasks,
          onTaskTap: (taskId) {
            final task =
                provider.filteredTasks.firstWhere((t) => t.id == taskId);
            _handleTaskTap(task, provider);
          },
          onTaskMoved: widget.isEditable
              ? (taskId, position) {
                  // provider.setTaskPosition(taskId, position);
                }
              : null,
          taskBuilder: (task) => _buildTaskNodeWidget(task, provider),
          isEditable: widget.isEditable,
        );
      },
    );
  }

  Widget _buildTaskNodeWidget(
      EnhancedTaskNode task, EnhancedWorkflowProvider provider) {
    final isHovered = _hoveredTaskId == task.id;
    final isSelected = _selectedTaskId == task.id;

    return TaskNodeWidget(
      task: task,
      isSelected: isSelected,
      isHovered: isHovered,
      onTap: () => _handleTaskTap(task, provider),
      onEdit:
          widget.isEditable ? () => _showEditTaskDialog(task, provider) : null,
      onDelete:
          widget.isEditable ? () => _handleDeleteTask(task, provider) : null,
    );
  }

  void _handleDeleteTask(
      EnhancedTaskNode task, EnhancedWorkflowProvider provider) {
    // TODO: 实现删除任务逻辑
    _showSnackBar('删除任务: ${task.title}');
  }

  // 应用连线模板
  void _applyConnectionTemplate(
      String template, EnhancedWorkflowProvider provider) {
    if (template == 'clear') {
      provider.clearAllConnections();
      _showSnackBar('已清除所有连线');
    } else {
      provider.generateWorkflowTemplate(template);
      String templateName;
      switch (template) {
        case 'linear':
          templateName = '线性流程';
          break;
        case 'parallel':
          templateName = '并行流程';
          break;
        case 'complex':
          templateName = '复杂流程';
          break;
        default:
          templateName = '流程';
      }
      _showSnackBar('已应用$templateName模板');
    }
  }

  // 交互处理方法
  void _handleTaskTap(
      EnhancedTaskNode task, EnhancedWorkflowProvider provider) {
    if (_showConnectionMode) {
      _handleConnectionModeTask(task, provider);
    } else {
      setState(() {
        _selectedTaskId = _selectedTaskId == task.id ? null : task.id;
      });
      widget.onTaskTap?.call(task.id);
    }
  }

  void _handleConnectionModeTask(
      EnhancedTaskNode task, EnhancedWorkflowProvider provider) {
    if (_connectionFromTaskId == null) {
      setState(() => _connectionFromTaskId = task.id);
    } else if (_connectionFromTaskId != task.id) {
      // provider.addTaskDependency(_connectionFromTaskId!, task.id);
      setState(() => _connectionFromTaskId = null);
      _showSnackBar('已添加任务依赖关系');
    }
  }

  void _toggleConnectionMode() {
    setState(() {
      _showConnectionMode = !_showConnectionMode;
      _connectionFromTaskId = null;
    });
  }

  void _toggleStatusFilter(
      EnhancedTaskStatus status, EnhancedWorkflowProvider provider) {
    setState(() {
      if (_statusFilter.contains(status)) {
        _statusFilter.remove(status);
      } else {
        _statusFilter.add(status);
      }
    });
    provider.setStatusFilter(_statusFilter);
  }

  void _togglePriorityFilter(
      EnhancedTaskPriority priority, EnhancedWorkflowProvider provider) {
    setState(() {
      if (_priorityFilter.contains(priority)) {
        _priorityFilter.remove(priority);
      } else {
        _priorityFilter.add(priority);
      }
    });
    provider.setPriorityFilter(_priorityFilter);
  }

  void _clearFilters(EnhancedWorkflowProvider provider) {
    setState(() {
      _statusFilter.clear();
      _priorityFilter.clear();
    });
    provider.clearFilters();
  }

  // 对话框方法
  void _showAddTaskDialog(EnhancedWorkflowProvider provider) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        availableTasks: provider.allTasks,
      ),
    ).then((result) {
      if (result != null && result is EnhancedTaskNode) {
        // provider.addTask(result);
        _showSnackBar('已添加任务: ${result.title}');
      }
    });
  }

  void _showEditTaskDialog(
      EnhancedTaskNode task, EnhancedWorkflowProvider provider) {
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        task: task,
        availableTasks: provider.allTasks,
      ),
    ).then((result) {
      if (result != null && result is EnhancedTaskNode) {
        // provider.updateTask(result);
        _showSnackBar('已更新任务: ${result.title}');
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
