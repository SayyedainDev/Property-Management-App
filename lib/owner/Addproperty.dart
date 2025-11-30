import "dart:typed_data";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:image_picker/image_picker.dart";
import "package:project/Model/OwnerModel.dart";
import "package:project/Statemangement/ownerP.dart";
import "package:provider/provider.dart";

class AddPropertyScreen extends StatefulWidget {
  final Ownermodel? existingProperty; // ✅ Pass this when editing

  const AddPropertyScreen({Key? key, this.existingProperty}) : super(key: key);

  @override
  _Addproperty createState() => _Addproperty();
}

class _Addproperty extends State<AddPropertyScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _City = TextEditingController();
  final TextEditingController _Description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _feature = TextEditingController();

  List<String> Feature = [];
  List<Uint8List> _selectedImages = [];
  List<String> _existingImageUrls = []; // ✅ For already uploaded images
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProperty != null) {
      // Prefill fields
      _title.text = widget.existingProperty!.title ?? '';
      _City.text = widget.existingProperty!.city ?? '';
      _Description.text = widget.existingProperty!.description ?? '';
      _price.text = widget.existingProperty!.price?.toString() ?? '';
      Feature = List<String>.from(widget.existingProperty!.features ?? []);
      _existingImageUrls = List<String>.from(
        widget.existingProperty!.images ?? [],
      );
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final List<Uint8List> bytesList = [];
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        bytesList.add(bytes);
      }
      setState(() {
        _selectedImages = bytesList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Ownerp>(context, listen: false);
    final bool isEditing = widget.existingProperty != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Property" : "Add Property")),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                // ✅ Show existing images + new ones
                GestureDetector(
                  onTap: pickImage,
                  child: Column(
                    children: [
                      (_existingImageUrls.isNotEmpty ||
                              _selectedImages.isNotEmpty)
                          ? SizedBox(
                              height: 120.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // Show existing images
                                  ..._existingImageUrls.map(
                                    (url) => Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: Image.network(
                                          url,
                                          height: 100.h,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.8,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Show newly picked images
                                  ..._selectedImages.map(
                                    (img) => Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: Image.memory(
                                          img,
                                          height: 100.h,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.8,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              height: 120.h,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 40.sp,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    "No images selected",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),

                // Text fields
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter Title" : null,
                ),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _Description,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter Description" : null,
                ),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _City,
                  decoration: InputDecoration(
                    labelText: "City",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter City" : null,
                ),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _price,
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Enter price" : null,
                ),
                SizedBox(height: 5.h),

                // Features
                TextFormField(
                  controller: _feature,
                  decoration: InputDecoration(
                    labelText: "Feature",
                    border: UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final text = _feature.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            Feature.add(text);
                            _feature.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Wrap(
                  children: Feature.map(
                    (f) => Chip(
                      label: Text(f),
                      onDeleted: () => setState(() => Feature.remove(f)),
                    ),
                  ).toList(),
                ),
                SizedBox(height: 10.h),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed: pickImage,
                      style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                      child: Text(
                        "Pick Images",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton(
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          try {
                            setState(() => _isloading = true);

                            if (isEditing) {
                              // ✅ Update existing property
                              await provider.updateProperty(
                                widget.existingProperty!.id!,
                                {
                                  'title': _title.text,
                                  'description': _Description.text,
                                  'city': _City.text,
                                  'price': double.tryParse(_price.text) ?? 0.0,
                                  'features': Feature,
                                  'images': [
                                    ..._existingImageUrls,
                                    // Upload new images and add URLs here
                                  ],
                                },
                              );
                            } else {
                              // ✅ Create new property
                              if (_selectedImages.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select images'),
                                  ),
                                );
                                setState(() => _isloading = false);
                                return;
                              }
                              provider.selectedImage.addAll(_selectedImages);
                              await provider.submitProperty(
                                title: _title.text,
                                description: _Description.text,
                                price: double.tryParse(_price.text) ?? 0.0,
                                city: _City.text,
                                features: Feature,
                              );
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Property updated!'
                                      : 'Property added!',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() => _isloading = false);
                          }
                        }
                      },
                      child: _isloading
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                              isEditing ? "Update" : "Submit",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
