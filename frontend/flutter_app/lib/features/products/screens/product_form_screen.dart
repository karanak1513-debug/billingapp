import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/repository_provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../widgets/app_product_image.dart';

/// Screen to Add a new Product or Edit an existing Product
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _portionController;
  late TextEditingController _badgeController;
  late TextEditingController _descriptionController;

  late String _selectedCategory;
  late bool _isActive;
  String _imagePath = '';
  File? _newPickedImageFile;

  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.sellingPrice.toStringAsFixed(0) : '',
    );
    _costPriceController = TextEditingController(
      text: p != null ? p.costPrice.toStringAsFixed(0) : '',
    );
    _portionController = TextEditingController(text: p?.portion ?? '/ portion');
    _badgeController = TextEditingController(text: p?.badge ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    _selectedCategory = p?.category ?? 'snacks';
    _isActive = p?.isActive ?? true;
    _imagePath = p?.imageAsset ?? '';

    // Rebuild on text change to keep live preview synced
    _nameController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _badgeController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _badgeController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _portionController.dispose();
    _badgeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _newPickedImageFile = File(picked.path);
          _imagePath = picked.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _newPickedImageFile = null;
      _imagePath = '';
    });
  }

  Future<void> _showNewCategoryDialog(List<String> existingCategories) async {
    final catController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. desserts, combomeals',
            filled: true,
            fillColor: AppColors.creamLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final text = catController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedCategory = result.toLowerCase().replaceAll(' ', '_');
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final sellingPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text.trim()) ?? (sellingPrice * 0.35);
    final portion = _portionController.text.trim().isEmpty ? '/ portion' : _portionController.text.trim();
    final badge = _badgeController.text.trim().isEmpty ? null : _badgeController.text.trim();
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    if (sellingPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selling price must be greater than ₹0'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(posRepositoryProvider);
      String persistentImagePath = _imagePath;

      // If user picked a new file from device gallery, copy to persistent app storage
      if (_newPickedImageFile != null && _newPickedImageFile!.existsSync()) {
        persistentImagePath = await repo.saveProductImageFile(_newPickedImageFile!);
      }

      final now = DateTime.now();
      final String productId = widget.product?.id ??
          '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${const Uuid().v4().substring(0, 6)}';

      final productToSave = Product(
        id: productId,
        name: name,
        category: _selectedCategory,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        portion: portion,
        imageAsset: persistentImagePath,
        badge: badge,
        description: description,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      await repo.saveProduct(productToSave);

      // Invalidate relevant providers to update all screens automatically
      ref.invalidate(productsProvider);
      ref.invalidate(adminProductsProvider);
      ref.invalidate(categoriesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Product "${productToSave.name}" updated successfully!'
                : 'Product "${productToSave.name}" created successfully!',
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      Navigator.pop(context, productToSave);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryList = categoriesAsync.asData?.value ?? ['snacks', 'drinks'];
    final displayCategories = Set<String>.from(categoryList);
    if (_selectedCategory.isNotEmpty) {
      displayCategories.add(_selectedCategory);
    }

    final previewPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final previewName = _nameController.text.trim().isEmpty ? 'Product Name' : _nameController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        title: Text(
          widget.isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Live Preview Card
              _buildLivePreviewCard(previewName, previewPrice),
              const SizedBox(height: 20),

              // Image Selector Section
              _buildImageSelectorCard(),
              const SizedBox(height: 20),

              // Core Product Details Card
              _buildDetailsCard(displayCategories.toList()),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard(String name, double price) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      color: AppColors.creamCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.terracotta),
                const SizedBox(width: 8),
                Text(
                  'LIVE MENU PREVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.terracotta,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isActive ? AppColors.successGreenLight : AppColors.errorRedLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isActive ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isActive ? AppColors.successGreen : AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.borderSubtle),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: AppProductImage(
                      imagePath: _imagePath,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_badgeController.text.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.caramelAccent.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _badgeController.text.trim(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.terracotta,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${_selectedCategory.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${price.toStringAsFixed(0)} ${_portionController.text.trim()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.burgundy,
                        ),
                      ),
                      if (_descriptionController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _descriptionController.text.trim(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectorCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      color: AppColors.creamCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Image',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select an image from your device gallery. Images are saved permanently in app storage and work offline.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: AppProductImage(
                      imagePath: _imagePath,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: Text(_imagePath.isEmpty ? 'Select Image' : 'Change Image'),
                      ),
                      if (_imagePath.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                            side: const BorderSide(color: AppColors.errorRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remove Image'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<String> categories) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      color: AppColors.creamCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Product Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Lemon Mojito, Peri Peri Fries',
                filled: true,
                fillColor: AppColors.creamLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.fastfood_outlined, color: AppColors.burgundy),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price in INR Field
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Selling Price (INR) *',
                hintText: 'e.g. 50',
                filled: true,
                fillColor: AppColors.creamLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    '₹',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.burgundy),
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Price in INR is required';
                }
                final numVal = double.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Selection + New Category Button
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: categories.contains(_selectedCategory) ? _selectedCategory : categories.first,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      filled: true,
                      fillColor: AppColors.creamLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category_outlined, color: AppColors.burgundy),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          cat.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.creamWarm,
                    foregroundColor: AppColors.burgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(14),
                  ),
                  tooltip: 'Create New Category',
                  onPressed: () => _showNewCategoryDialog(categories),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Availability Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.creamLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                        color: _isActive ? AppColors.successGreen : AppColors.errorRed,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Availability',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            _isActive ? 'Available for new sales & billing' : 'Hidden from active billing',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppColors.successGreen,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Portion & Badge Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _portionController,
                    decoration: InputDecoration(
                      labelText: 'Portion / Unit',
                      hintText: 'e.g. / portion, / 350ml',
                      filled: true,
                      fillColor: AppColors.creamLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _badgeController,
                    decoration: InputDecoration(
                      labelText: 'Badge (Optional)',
                      hintText: 'e.g. Bestseller, Spicy',
                      filled: true,
                      fillColor: AppColors.creamLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Optional Cost Price
            TextFormField(
              controller: _costPriceController,
              decoration: InputDecoration(
                labelText: 'Cost Price (Optional - for profit tracking)',
                hintText: 'e.g. 20',
                filled: true,
                fillColor: AppColors.creamLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),

            // Optional Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Short description of flavors, ingredients or serving style',
                filled: true,
                fillColor: AppColors.creamLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.burgundy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: _isSaving ? null : _saveProduct,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  widget.isEditing ? 'Save Product' : 'Create Product',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.borderMedium),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}
