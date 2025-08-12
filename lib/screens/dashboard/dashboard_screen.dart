import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  _buildSliverAppBar(context, authProvider),

                  // Dashboard Content
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: AppSizes.md),

                          // Financial Overview Cards
                          _buildFinancialOverview(),

                          const SizedBox(height: AppSizes.lg),

                          // Quick Actions
                          _buildQuickActions(),

                          const SizedBox(height: AppSizes.lg),

                          // Recent Transactions
                          _buildRecentTransactions(),

                          const SizedBox(height: AppSizes.lg),

                          // Budget Overview
                          _buildBudgetOverview(),

                          const SizedBox(height: AppSizes.xl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.xs,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: AppColors.white, size: 20),
                  ),
                  const SizedBox(width: AppSizes.sm),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat datang,',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                        ),
                        Text(
                          authProvider.user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Logout Button
                  IconButton(
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
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

  Widget _buildFinancialOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Keuangan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Balance Card (Main)
          _buildBalanceCard(),

          const SizedBox(height: AppSizes.md),

          // Income & Expense Cards
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  title: 'Pemasukan',
                  amount: 'Rp 5.250.000',
                  icon: Icons.arrow_upward,
                  color: AppColors.success,
                  isIncome: true,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildFinancialCard(
                  title: 'Pengeluaran',
                  amount: 'Rp 3.750.000',
                  icon: Icons.arrow_downward,
                  color: AppColors.error,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Saldo Total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.visibility,
                color: AppColors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Rp 1.500.000',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.greenAccent,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '+12.5% dari bulan lalu',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Tambah\nPemasukan',
                  icon: Icons.add_circle,
                  color: AppColors.success,
                  onTap: () {
                    // Navigate to Add Income
                    _showComingSoonSnackBar('Tambah Pemasukan');
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Tambah\nPengeluaran',
                  icon: Icons.remove_circle,
                  color: AppColors.error,
                  onTap: () {
                    // Navigate to Add Expense
                    _showComingSoonSnackBar('Tambah Pengeluaran');
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Lihat\nLaporan',
                  icon: Icons.bar_chart,
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to Reports
                    _showComingSoonSnackBar('Laporan');
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Atur\nBudget',
                  icon: Icons.pie_chart,
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to Budget
                    _showComingSoonSnackBar('Budget');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transaksi Terbaru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showComingSoonSnackBar('Semua Transaksi');
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTransactionItem(
                  title: 'Gaji Bulanan',
                  subtitle: 'Hari ini • 14:30',
                  amount: '+Rp 5.000.000',
                  icon: Icons.work,
                  color: AppColors.success,
                ),
                const Divider(height: 1),
                _buildTransactionItem(
                  title: 'Belanja Groceries',
                  subtitle: 'Kemarin • 10:15',
                  amount: '-Rp 150.000',
                  icon: Icons.shopping_cart,
                  color: AppColors.error,
                ),
                const Divider(height: 1),
                _buildTransactionItem(
                  title: 'Transfer ke Tabungan',
                  subtitle: '2 hari lalu • 09:00',
                  amount: '-Rp 500.000',
                  icon: Icons.savings,
                  color: AppColors.error,
                ),
                const Divider(height: 1),
                _buildTransactionItem(
                  title: 'Freelance Project',
                  subtitle: '3 hari lalu • 16:45',
                  amount: '+Rp 750.000',
                  icon: Icons.laptop,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Budget Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showComingSoonSnackBar('Kelola Budget');
                },
                child: const Text('Kelola'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildBudgetItem(
                  category: 'Makanan & Minuman',
                  spent: 450000,
                  budget: 600000,
                  color: Colors.orange,
                ),
                const SizedBox(height: AppSizes.md),
                _buildBudgetItem(
                  category: 'Transport',
                  spent: 200000,
                  budget: 300000,
                  color: Colors.blue,
                ),
                const SizedBox(height: AppSizes.md),
                _buildBudgetItem(
                  category: 'Hiburan',
                  spent: 180000,
                  budget: 200000,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem({
    required String category,
    required double spent,
    required double budget,
    required Color color,
  }) {
    final percentage = spent / budget;
    final isOverBudget = percentage > 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Rp ${spent.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? AppColors.error : color,
              ),
            ),
            Text(
              ' / Rp ${budget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        LinearProgressIndicator(
          value: percentage.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverBudget ? AppColors.error : color,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddTransactionBottomSheet();
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[400],
        elevation: 0,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Dashboard
              break;
            case 1:
              _showComingSoonSnackBar('Transaksi');
              break;
            case 2:
              _showComingSoonSnackBar('Budget');
              break;
            case 3:
              _showComingSoonSnackBar('Laporan');
              break;
            case 4:
              _showComingSoonSnackBar('Profil');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              );

              try {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout gagal: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Tambah Transaksi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildTransactionTypeButton(
                    title: 'Pemasukan',
                    icon: Icons.add_circle,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar('Tambah Pemasukan');
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTransactionTypeButton(
                    title: 'Pengeluaran',
                    icon: Icons.remove_circle,
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar('Tambah Pengeluaran');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
