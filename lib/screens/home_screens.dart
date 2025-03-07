import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_form.dart';
import '../models/todo.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});
  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSubject = 'Semua Matakuliah';
  String _selectedDifficulty = 'Semua Tingkat';
  String _selectedSort = 'Deadline Terdekat';
  bool _isFilterExpanded = false;
  final List<String> _subjects = [
    'Semua Matakuliah',
    'PRATIKUM MACHINE LEARNING',
    'PRATIKUM PEMROGRAMAN GAME',
    'PRATIKUM PEMROGRAMAN ROBOTIKA',
    'MACHINE LEARNING',
    'KOMPUTASI AWAN',
    'BAHASA INDONESIA',
    'KEAMANAN JARINGAN',
    'BAHASA INGGRIS III',
    'PEMROGRAMAN ROBOTIKA',
    'PEMROGRAMAN GAME FF GENAP',
    'SISTEM PAKAR DAN BAHASA ALAMIAH',
    'PENGENALAN UCAPAN DAN TEKS KE UCAPAN',
  ];
  final List<String> _difficulties = [
    'Semua Tingkat',
    'Mudah',
    'Sedang',
    'Sulit',
  ];
  final List<String> _sortOptions = [
    'Deadline Terdekat',
    'Deadline Terjauh',
    'Nama A-Z',
    'Nama Z-A',
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Jadwalkan pengingat harian
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).scheduleDailyReminder();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTodoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTodoForm(),
      ),
    );
  }

  List<Todo> _filterAndSortTodos(List<Todo> todos) {
    // Filter berdasarkan matakuliah
    List<Todo> filteredTodos = todos;
    if (_selectedSubject != 'Semua Matakuliah') {
      filteredTodos = filteredTodos
          .where((todo) => todo.subject == _selectedSubject)
          .toList();
    }
    // Filter berdasarkan tingkat kesulitan
    if (_selectedDifficulty != 'Semua Tingkat') {
      filteredTodos = filteredTodos
          .where((todo) => todo.difficulty == _selectedDifficulty)
          .toList();
    }
    // Urutkan berdasarkan pilihan
    switch (_selectedSort) {
      case 'Deadline Terdekat':
        filteredTodos.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'Deadline Terjauh':
        filteredTodos.sort((a, b) => b.deadline.compareTo(a.deadline));
        break;
      case 'Nama A-Z':
        filteredTodos.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Nama Z-A':
        filteredTodos.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    return filteredTodos;
  }

  Widget _buildFilterChip(String label, String selectedValue,
      List<String> options, Function(String) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selectedValue == options[0] ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        selected: selectedValue != options[0],
        selectedColor: const Color(0xFF689F38),
        backgroundColor: Colors.white,
        onSelected: (_) {
          _showFilterOptions(label, options, selectedValue, onSelected);
        },
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showFilterOptions(String title, List<String> options,
      String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Pilih $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      trailing: currentValue == option
                          ? const Icon(Icons.check, color: Color(0xFF689F38))
                          : null,
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF8BC34A),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF8BC34A), Color(0xFF558B2F)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -40,
                        bottom: 0,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: 40,
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Consumer<TodoProvider>(
                                builder: (context, provider, _) {
                                  final pendingCount =
                                      provider.pendingTodos.length;
                                  return Text(
                                    'Anda memiliki $pendingCount tugas tertunda',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFilterExpanded
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                ),
              ],
            ),
            if (_isFilterExpanded)
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter & Urutkan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _selectedSubject == 'Semua Matakuliah' &&
                                    _selectedDifficulty == 'Semua Tingkat' &&
                                    _selectedSort == 'Deadline Terdekat'
                                ? 'Belum ada filter yang dipilih'
                                : 'Filter aktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Matakuliah',
                              _selectedSubject,
                              _subjects,
                              (value) {
                                setState(() {
                                  _selectedSubject = value;
                                });
                              },
                            ),
                            _buildFilterChip(
                              'Tingkat Kesulitan',
                              _selectedDifficulty,
                              _difficulties,
                              (value) {
                                setState(() {
                                  _selectedDifficulty = value;
                                });
                              },
                            ),
                            _buildFilterChip(
                              'Urutkan',
                              _selectedSort,
                              _sortOptions,
                              (value) {
                                setState(() {
                                  _selectedSort = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedSubject != 'Semua Matakuliah' ||
                          _selectedDifficulty != 'Semua Tingkat' ||
                          _selectedSort != 'Deadline Terdekat')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_selectedSubject != 'Semua Matakuliah')
                                _buildActiveFilterChip(
                                  _selectedSubject,
                                  () {
                                    setState(() {
                                      _selectedSubject = 'Semua Matakuliah';
                                    });
                                  },
                                ),
                              if (_selectedDifficulty != 'Semua Tingkat')
                                _buildActiveFilterChip(
                                  _selectedDifficulty,
                                  () {
                                    setState(() {
                                      _selectedDifficulty = 'Semua Tingkat';
                                    });
                                  },
                                ),
                              if (_selectedSort != 'Deadline Terdekat')
                                _buildActiveFilterChip(
                                  _selectedSort,
                                  () {
                                    setState(() {
                                      _selectedSort = 'Deadline Terdekat';
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFAED581), Color(0xFFDCEDC8)],
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pending todos tab
              _buildTodoList(isPending: true),

              // Completed todos tab
              _buildTodoList(isPending: false),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoBottomSheet,
        backgroundColor: const Color(0xFF689F38),
        elevation: 8,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Tambah Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF689F38),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: Colors.white,
      ),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTodoList({required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<TodoProvider>(
        builder: (ctx, todoProvider, _) {
          var todos = isPending
              ? todoProvider.pendingTodos
              : todoProvider.completedTodos;

          // Terapkan filter dan pengurutan
          todos = _filterAndSortTodos(todos);

          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPending ? Icons.assignment : Icons.assignment_turned_in,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPending
                        ? 'Tidak ada tugas yang tertunda. Tambahkan beberapa!'
                        : 'Belum ada tugas yang selesai.',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: todos.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TodoItem(
                  todo: todos[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
