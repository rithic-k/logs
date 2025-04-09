import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = '0xe5d8'; // Default icon code
  bool _isExpense = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildCategoryList(
                  provider.categories.where((c) => c.isExpense).toList(),
                ),
                _buildCategoryList(
                  provider.categories.where((c) => !c.isExpense).toList(),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No categories yet',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Icon(
                IconData(
                  int.parse(category.icon),
                  fontFamily: 'MaterialIcons',
                ),
                color: Colors.white,
              ),
            ),
            title: Text(
              category.name,
              style: AppTextStyles.body1,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCategory(category),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    _nameController.clear();
    _selectedIcon = '0xe5d8';
    _isExpense = true;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
                decoration: const InputDecoration(
                  labelText: 'Icon',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '0xe5d8',
                    child: Row(
                      children: [
                        Icon(Icons.category),
                        SizedBox(width: 8),
                        Text('Category'),
                      ],
                    ),
                  ),
                  // Add more icons as needed
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedIcon = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Expense Category'),
                value: _isExpense,
                onChanged: (bool value) {
                  setState(() {
                    _isExpense = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isLoading ? null : () => _saveCategory(context),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final category = Category(
        name: _nameController.text,
        icon: _selectedIcon,
        isExpense: _isExpense,
      );

      await provider.addCategory(category);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save category')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory(Category category) async {
    // Implement delete functionality
    // You'll need to add this method to the TransactionProvider
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
