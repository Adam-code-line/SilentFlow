import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  // 3D交互相关状态
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;

  // 动画控制器
  late AnimationController _tiltController;
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _tiltAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _tiltController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 创建动画
    _tiltAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tiltController.dispose();
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  // 鼠标进入卡片
  void _onCardEnter() {
    setState(() {
      _scale = 1.03;
    });
    _scaleController.forward();
  }

  // 鼠标离开卡片
  void _onCardExit() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _scale = 1.0;
    });
    _tiltController.reverse();
    _scaleController.reverse();
  }

  // 鼠标在卡片上移动
  void _onCardHover(PointerHoverEvent details) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);

    // 计算鼠标相对于卡片中心的位置
    final mousePosition = details.localPosition;
    final deltaX = (mousePosition.dx - center.dx) / center.dx;
    final deltaY = (mousePosition.dy - center.dy) / center.dy;

    // 最大旋转角度（弧度）
    const maxTilt = 0.3; // 约17度

    setState(() {
      _rotationY = deltaX * maxTilt;
      _rotationX = -deltaY * maxTilt;
    });

    _tiltController.forward();
  }

  // 点击波纹效果
  void _triggerRipple() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 动态渐变背景
          AnimatedContainer(
            duration: const Duration(seconds: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo[300]!,
                  Colors.purple[400]!,
                  Colors.pink[300]!,
                  Colors.orange[300]!,
                ],
              ),
            ),
          ),

          // 浮动粒子效果背景
          ...List.generate(20, (index) => _buildFloatingParticle(index)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo区域
                    _buildLogoSection(),
                    const SizedBox(height: 40),

                    // 3D液态玻璃登录卡片
                    _build3DGlassCard(),
                    const SizedBox(height: 24),

                    // 底部提示
                    _buildFooterText(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return Positioned(
      left: (index * 37) % MediaQuery.of(context).size.width,
      top: (index * 67) % MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        duration: Duration(seconds: 3 + (index % 3)),
        tween: Tween(begin: 0.0, end: 1.0),
        onEnd: () => setState(() {}),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(value * 2 * math.pi) * 30,
              math.cos(value * 2 * math.pi) * 20,
            ),
            child: Container(
              width: 4 + (index % 3) * 2,
              height: 4 + (index % 3) * 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.psychology,
              size: 60,
              color: Colors.indigo[600],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '静默协作',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '用技术连接人心，以数据驱动效率',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _build3DGlassCard() {
    return MouseRegion(
      onEnter: (_) => _onCardEnter(),
      onExit: (_) => _onCardExit(),
      onHover: (details) => _onCardHover(details),
      child: GestureDetector(
        onTap: _triggerRipple,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_tiltAnimation, _scaleAnimation, _rippleAnimation]),
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 透视效果
                ..rotateX(_rotationX * _tiltAnimation.value)
                ..rotateY(_rotationY * _tiltAnimation.value)
                ..scale(_scale * _scaleAnimation.value),
              child: Stack(
                children: [
                  // 主要玻璃卡片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: _buildGlassForm(),
                      ),
                    ),
                  ),

                  // 波纹效果
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: _rippleAnimation.value,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          _buildFormTitle(),
          const SizedBox(height: 8),
          Text(
            _isLogin ? '登录您的账户继续使用' : '创建新账户开始协作',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 用户名输入框
          _buildGlassTextField(
            controller: _usernameController,
            label: '用户名',
            hint: '请输入用户名',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              if (value.length < 3) {
                return '用户名至少3个字符';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 密码输入框
          _buildGlassTextField(
            controller: _passwordController,
            label: '密码',
            hint: '请输入密码',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少6位';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // 登录按钮
          _buildGlassButton(),
          const SizedBox(height: 24),

          // 分割线
          _buildDivider(),
          const SizedBox(height: 24),

          // 切换登录/注册
          _buildToggleButton(),

          // 错误信息显示
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (appProvider.error != null) {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // 使用更强烈的背景色提高对比度
                    color: Colors.red[900]!.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red[400]!.withOpacity(0.6),
                      width: 1.5,
                    ),
                    // 添加阴影增强视觉效果
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[400]!.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red[100], // 更亮的颜色
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appProvider.error!,
                          style: const TextStyle(
                            color: Colors.white, // 使用白色文字提高对比度
                            fontSize: 14,
                            fontWeight: FontWeight.w500, // 增加字重
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo[400]!,
                Colors.indigo[600]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isLogin ? Icons.login : Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _isLogin ? '欢迎回来' : '加入我们',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.indigo[300]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[300]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[300]!, width: 2),
          ),
          errorStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo[400]!.withOpacity(0.8),
                      Colors.indigo[600]!.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: appProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: appProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isLogin ? Icons.login : Icons.person_add,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isLogin ? '立即登录' : '创建账户',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或者',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            _isLogin = !_isLogin;
          });
          context.read<AppProvider>().clearError();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLogin ? Icons.person_add_outlined : Icons.login_outlined,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isLogin ? '还没有账号？立即注册' : '已有账号？立即登录',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      '登录即表示您同意我们的服务条款和隐私政策',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = context.read<AppProvider>();

      bool success;
      if (_isLogin) {
        success = await appProvider.login(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        success = await appProvider.register(
          _usernameController.text,
          _passwordController.text,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? '登录成功！' : '注册成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
