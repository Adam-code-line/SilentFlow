import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/team_pool_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/dialogs/task_creation_dialog.dart';
import '../../widgets/task/task_search_filter_bar.dart';
import '../../widgets/cards/task_card_widget.dart';
import '../../widgets/cards/project_card_widget.dart';
import '../workflow/workflow_screen.dart';
import 'task_detail_screen.dart';

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _tasks = [];
  List<Task> _myTasks = [];
  List<Task> _availableTasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TeamPoolProvider? _teamPoolProvider; // 添加引用变量

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 🆕 立即加载任务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();

      // 监听团队池变化，自动刷新任务
      _teamPoolProvider = context.read<TeamPoolProvider>();
      _teamPoolProvider!.addListener(_onTeamPoolChanged);
    });
  }

  @override
  void dispose() {
    // 🆕 安全移除监听器
    _teamPoolProvider?.removeListener(_onTeamPoolChanged);
    _tabController.dispose();
    super.dispose();
  }

  // 🆕 团队池变化处理
  void _onTeamPoolChanged() {
    print('TaskBoardScreen: 团队池发生变化，重新加载任务');
    // 🔧 减少延迟时间，更快响应变化
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _loadTasks();
      }
    });
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = context.read<AppProvider>();
      final teamPoolProvider = context.read<TeamPoolProvider>();
      final userId = appProvider.currentUser?.id;

      if (userId == null) {
        print('TaskBoardScreen: 用户ID为空，无法加载任务');
        setState(() {
          _tasks = [];
          _myTasks = [];
          _availableTasks = [];
          _isLoading = false;
        });
        return;
      }

      print('TaskBoardScreen: 开始加载用户 $userId 的任务');
      print('TaskBoardScreen: 当前团队池数量: ${teamPoolProvider.teamPools.length}');

      // 🔧 修复：确保先获取用户的团队列表
      final userTeams = teamPoolProvider.teamPools
          .where((team) =>
              team.memberIds.contains(userId) || team.leaderId == userId)
          .toList();

      print('TaskBoardScreen: 用户参与的团队数量: ${userTeams.length}');
      for (var team in userTeams) {
        print('TaskBoardScreen: 团队 - ID: ${team.id}, 名称: ${team.name}');
      }

      _tasks = [];

      // 🔧 增强：并行加载所有团队的任务，提高效率
      final taskLoadFutures = userTeams.map((team) async {
        try {
          print('TaskBoardScreen: 加载团队 ${team.id} (${team.name}) 的任务');
          final teamTasks = await TaskService.getTeamTasks(team.id);
          print('TaskBoardScreen: 团队 ${team.id} 加载到 ${teamTasks.length} 个任务');
          return teamTasks;
        } catch (e) {
          print('TaskBoardScreen: 加载团队 ${team.id} 的任务失败: $e');
          return <Task>[];
        }
      }).toList();

      // 等待所有团队任务加载完成
      final allTeamTasks = await Future.wait(taskLoadFutures);

      // 合并所有团队的任务
      for (final teamTasks in allTeamTasks) {
        _tasks.addAll(teamTasks);
      }

      print('TaskBoardScreen: 总共加载了 ${_tasks.length} 个任务');

      // 🔧 优化：任务分类逻辑
      _myTasks = _tasks
          .where((task) =>
              task.assignedUsers.contains(userId) || task.assigneeId == userId)
          .toList();

      _availableTasks = _tasks
          .where((task) =>
              task.status == TaskStatus.pending &&
              !task.assignedUsers.contains(userId) &&
              task.assigneeId != userId)
          .toList();

      print('TaskBoardScreen: 我的任务: ${_myTasks.length} 个');
      print('TaskBoardScreen: 可认领任务: ${_availableTasks.length} 个');

      setState(() {});
    } catch (e) {
      print('TaskBoardScreen: 加载任务异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载任务失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    var filtered = tasks;

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (task.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              task.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    // 状态过滤
    if (_filterStatus != null) {
      filtered =
          filtered.where((task) => task.status == _filterStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 使用Consumer监听团队池变化
    return Consumer<TeamPoolProvider>(
      builder: (context, teamPoolProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('任务面板'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.assignment_ind), text: '我的任务'),
                Tab(icon: Icon(Icons.assignment), text: '可认领'),
                Tab(icon: Icon(Icons.dashboard), text: '全部任务'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_tree),
                tooltip: '工作流图',
                onPressed: () => _navigateToWorkflowGraph(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTasks,
              ),
              // 🔧 修改显示逻辑：显示更详细的调试信息
              if (teamPoolProvider.teamPools.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${teamPoolProvider.teamPools.length}团',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        '${_tasks.length}任务',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // 搜索和筛选栏
              TaskSearchAndFilterBar(
                searchQuery: _searchQuery,
                filterStatus: _filterStatus,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onFilterChanged: (status) {
                  setState(() {
                    _filterStatus = status;
                  });
                },
              ),

              // 任务列表
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildHierarchicalTaskList(
                              _getFilteredTasks(_myTasks), true),
                          _buildHierarchicalTaskList(
                              _getFilteredTasks(_availableTasks), false),
                          _buildHierarchicalTaskList(
                              _getFilteredTasks(_tasks), false),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateTaskDialog(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildHierarchicalTaskList(List<Task> tasks, bool isMyTasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isMyTasks ? '暂无分配的任务' : '暂无可认领的任务',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    // 按层级组织任务
    final projects = tasks.where((t) => t.level == TaskLevel.project).toList();
    final regularTasks = tasks
        .where((t) => t.level == TaskLevel.task && t.parentTaskId == null)
        .toList();
    final taskPoints =
        tasks.where((t) => t.level == TaskLevel.taskPoint).toList();

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 显示项目级任务
          if (projects.isNotEmpty) ...[
            _buildSectionHeader('项目 (${projects.length})'),
            ...projects.map((project) => ProjectCard(
                  project: project,
                  allTasks: tasks,
                  isMyTask: false,
                  onTaskAction: (task, action) =>
                      _handleTaskAction(task, action),
                )),
            const SizedBox(height: 16),
          ],

          // 显示独立任务（不属于任何项目的任务）
          if (regularTasks.isNotEmpty) ...[
            _buildSectionHeader('独立任务 (${regularTasks.length})'),
            ...regularTasks.map((task) => TaskCard(
                  task: task,
                  onTap: () => _showTaskDetails(task),
                )),
            const SizedBox(height: 16),
          ],

          // 显示孤立的任务点（如果有的话）
          if (taskPoints
              .any((tp) => !tasks.any((t) => t.id == tp.parentTaskId))) ...[
            _buildSectionHeader('其他任务点'),
            ...taskPoints
                .where((tp) => !tasks.any((t) => t.id == tp.parentTaskId))
                .map((task) => TaskCard(
                      task: task,
                      onTap: () => _showTaskDetails(task),
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.label, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const Expanded(child: Divider(indent: 16)),
        ],
      ),
    );
  }

  void _handleTaskAction(Task task, String action) {
    switch (action) {
      case 'assign':
        _claimTask(task);
        break;
      case 'edit':
        _editTask(task);
        break;
      case 'status':
        _changeTaskStatus(task);
        break;
      case 'delete':
        _deleteTask(task);
        break;
      case 'create_subtask':
        _createSubTask(task);
        break;
      case 'start':
        _startTask(task);
        break;
      case 'complete':
        _completeTask(task);
        break;
      case 'block':
        _blockTask(task);
        break;
      case 'details':
        _showTaskDetails(task);
        break;
    }
  }

  Future<void> _createSubTask(Task parentTask) async {
    final teamPoolProvider = context.read<TeamPoolProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: teamPoolProvider.currentTeam,
        parentTask: parentTask,
      ),
    );

    if (result == true) {
      _loadTasks(); // 重新加载任务列表
    }
  }

  Future<void> _startTask(Task task) async {
    try {
      await TaskService.updateTaskStatus(
        teamId: task.poolId,
        taskId: task.id,
        status: TaskStatus.inProgress,
      );
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已开始')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始任务失败: $e')),
        );
      }
    }
  }

  Future<void> _completeTask(Task task) async {
    try {
      await TaskService.updateTaskStatus(
        teamId: task.poolId,
        taskId: task.id,
        status: TaskStatus.completed,
      );
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已完成')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('完成任务失败: $e')),
        );
      }
    }
  }

  Future<void> _blockTask(Task task) async {
    try {
      await TaskService.updateTaskStatus(
        teamId: task.poolId,
        taskId: task.id,
        status: TaskStatus.blocked,
      );
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已标记为阻塞')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('阻塞任务失败: $e')),
        );
      }
    }
  }

  void _showTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    ).then((result) {
      if (result == true) {
        _loadTasks(); // 如果任务被修改或删除，重新加载任务列表
      }
    });
  }

  Future<void> _showCreateTaskDialog() async {
    final teamPoolProvider = context.read<TeamPoolProvider>();

    // 🔧 确保有可用的团队
    if (teamPoolProvider.teamPools.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先创建或加入团队，然后再创建任务'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: teamPoolProvider.currentTeam ?? teamPoolProvider.teamPools.first,
      ),
    );

    if (result == true) {
      print('TaskBoardScreen: 任务创建成功，重新加载任务列表');
      _loadTasks();
    }
  }

  void _navigateToWorkflowGraph() {
    final teamPoolProvider = context.read<TeamPoolProvider>();

    if (teamPoolProvider.teamPools.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('您还没有加入任何团队，请先创建或加入团队'),
          backgroundColor: Color(0xFFED8936),
        ),
      );
      return;
    }

    // 🔧 选择当前团队或第一个可用团队
    final selectedTeam =
        teamPoolProvider.currentTeam ?? teamPoolProvider.teamPools.first;

    print('TaskBoardScreen: 导航到工作流图，团队: ${selectedTeam.name}');

    // 直接导航到工作流页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkflowScreen(
          teamId: selectedTeam.id,
        ),
      ),
    );
  }

  Future<void> _claimTask(Task task) async {
    final appProvider = context.read<AppProvider>();
    final userId = appProvider.currentUser?.id;

    if (userId == null) return;

    try {
      await TaskService.updateTaskStatus(
        teamId: task.poolId,
        taskId: task.id,
        status: TaskStatus.inProgress,
        assigneeId: userId,
      );
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已认领')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('认领任务失败: $e')),
        );
      }
    }
  }

  void _editTask(Task task) {
    // TODO: 实现任务编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('任务编辑功能开发中')),
    );
  }

  void _changeTaskStatus(Task task) {
    // TODO: 实现状态更改功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('状态更改功能开发中')),
    );
  }

  void _deleteTask(Task task) {
    // TODO: 实现任务删除功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('任务删除功能开发中')),
    );
  }
}
