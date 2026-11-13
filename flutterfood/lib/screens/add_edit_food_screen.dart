import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../providers/locale_provider.dart';

class AddEditFoodScreen extends StatefulWidget {
  final FoodItem? foodItem;

  const AddEditFoodScreen({super.key, this.foodItem});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem?.name ?? '');
    _priceController = TextEditingController(text: widget.foodItem?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.foodItem?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.foodItem?.imageUrl ?? '');
    _categoryController = TextEditingController(text: widget.foodItem?.category ?? 'General');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = FoodItem(
        id: widget.foodItem?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imageUrl: _pickedImage?.path ?? _imageUrlController.text,
        category: _categoryController.text,
      );

      if (widget.foodItem == null) {
        Provider.of<FoodProvider>(context, listen: false).addFood(newItem);
      } else {
        Provider.of<FoodProvider>(context, listen: false).updateFood(widget.foodItem!.id, newItem);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem == null
            ? localeProvider.translate('add_food')
            : localeProvider.translate('edit_food')),
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFCFAF5),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                      image: _pickedImage != null
                          ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                          : (_imageUrlController.text.isNotEmpty
                              ? DecorationImage(image: NetworkImage(_imageUrlController.text), fit: BoxFit.cover)
                              : null),
                    ),
                    child: _pickedImage == null && _imageUrlController.text.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                localeProvider.translate('tap_to_browse_image'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, size: 18),
                label: Text(localeProvider.translate('browse_gallery')),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localeProvider.translate('food_name'),
                  prefixIcon: const Icon(Icons.fastfood_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty ? localeProvider.translate('enter_name') : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: localeProvider.translate('price'),
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value!) == null ? localeProvider.translate('enter_valid_price') : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: localeProvider.translate('category'),
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (value) => value!.isEmpty ? localeProvider.translate('enter_category') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: localeProvider.translate('description'),
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? localeProvider.translate('enter_description') : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _imageUrlController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: localeProvider.translate('image_url'),
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    widget.foodItem == null
                        ? localeProvider.translate('add_item')
                        : localeProvider.translate('update_item'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
