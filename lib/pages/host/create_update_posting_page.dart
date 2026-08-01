import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/global.dart';
import 'package:otel_ve_emlak_kiralama/models/posting_objects.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/host_home_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/search_property_location_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/facilities_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class CreateUpdatePostingPage extends StatefulWidget {
  final Posting? posting;

  const CreateUpdatePostingPage({super.key, this.posting});

  @override
  State<CreateUpdatePostingPage> createState() => _CreateUpdatePostingPageState();
}

class _CreateUpdatePostingPageState extends State<CreateUpdatePostingPage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _amenitiesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<String> _propertyTypes = [
    'müstakil ev',
    'villa',
    'apartman dairesi',
    'rezidans',
    'daire',
    'sıralı ev',
    'stüdyo daire',
    'oda',
  ];

  String? _propertyTypeChosen;

  Map<String, int>? _beds;
  Map<String, int>? _bathrooms;
  List<MemoryImage>? _images;
  bool _isLoading = false;

  _setUpInitialValuesForTextFields() {
    if (widget.posting ==
        null) { //ilk değer boşsa, bu yeni bir gönderi demektir.
      _beds = {'küçük': 0, 'orta': 0, 'büyük': 0};
      _bathrooms = {'tam': 0, 'yarım': 0};
      _images = [];
      _nameController = TextEditingController(text: "");
      _priceController = TextEditingController(text: "");
      _descriptionController = TextEditingController(text: "");
      _addressController = TextEditingController(text: "");
      _cityController = TextEditingController(text: "");
      _countryController = TextEditingController(text: "");
      _amenitiesController = TextEditingController(text: "");
    } else {
      _nameController = TextEditingController(text: widget.posting!.name);
      _priceController = TextEditingController(text: widget.posting!.price.toString());
      _descriptionController = TextEditingController(text: widget.posting!.description);
      _addressController = TextEditingController(text: widget.posting!.address);
      _cityController = TextEditingController(text: widget.posting!.city);
      _countryController = TextEditingController(text: widget.posting!.country);
      _amenitiesController = TextEditingController(text: widget.posting!.getAmenititesString());
      _beds = widget.posting!.beds;
      _bathrooms = widget.posting!.bathrooms;
      _images = widget.posting!.displayImages;
      _propertyTypeChosen = widget.posting!.type;
    }
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setUpInitialValuesForTextFields();
  }

  _selectImage(int index) async {
    final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (pickedImage != null) {
      // Convert XFile → File
      File originalFile = File(pickedImage.path);

      // Temporary directory for compressed file
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        "compressed_${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg",
      );

      // Compress image bytes (e.g., 15% quality)
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.path,
        quality: 15,
      );

      if (compressedBytes != null) {
        // Write compressed bytes to a new File
        final compressedFile = File(targetPath)
          ..writeAsBytesSync(compressedBytes);

        // Convert to MemoryImage
        MemoryImage newImage = MemoryImage(compressedFile.readAsBytesSync());

        // Check for duplicate by comparing bytes
        bool isDuplicate = _images!.any((img) {
          final bytes = (img as MemoryImage).bytes;
          if (bytes.length != compressedBytes.length) return false;

          for (int i = 0; i < bytes.length; i++) {
            if (bytes[i] != compressedBytes[i]) return false;
          }

          return true;
        });

        if (isDuplicate) {
          // show a message to user
          CommonFunctions.showSnackBar(context, "Bu görseli zaten seçtiniz.");
          return; // Exit without adding
        }

        // Add image in your images list
        if (index < 0) {
          _images!.add(newImage);
        } else {
          _images![index] = newImage;
        }

        setState(() {});
      }
    }
  }

  _storePosting() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_propertyTypeChosen == null) {
      return;
    }
    if (_images!.isEmpty) {
      return;
    }

    setState(() {
      _isLoading=true;
    });

    Posting posting= Posting();
    posting.name = _nameController.text.toLowerCase();
    posting.price = double.parse(_priceController.text);
    posting.description = _descriptionController.text.toLowerCase();
    posting.address = _addressController.text.toLowerCase();
    posting.city = _cityController.text.toLowerCase();
    posting.country = _countryController.text.toLowerCase();
    posting.amenities = _amenitiesController.text.toLowerCase().split(",");
    posting.type = _propertyTypeChosen!.toLowerCase();
    posting.beds = _beds;
    posting.bathrooms = _bathrooms;
    posting.displayImages = _images;
    posting.host = AppConstants.currentUser.createContactFromUser();
    posting.setImageNames();

    if (widget.posting == null) {
      posting.rating = 2.5;
      posting.bookings = [];
      posting.reviews = [];
      posting.addPostingInfoToFirestore().whenComplete(() {
        posting.addImagesToFirestore().whenComplete(() {

          setState(() {
            _isLoading = false;
          });

          CommonFunctions.showSnackBar(context, "Yeni emlak ilanınız başarıyla yüklendi.");
          Navigator.push(context, MaterialPageRoute(builder: (context) => HostHomePage(index: 1)));
        });
      });
    } else {
      posting.rating = widget.posting!.rating;
      posting.bookings = widget.posting!.bookings;
      posting.reviews = widget.posting!.reviews;
      posting.id = widget.posting!.id;

      for (int i = 0; i < AppConstants.currentUser.myPostings!.length; i++) {
        if (AppConstants.currentUser.myPostings![i].id == posting.id) {
          AppConstants.currentUser.myPostings![i] = posting;
          break;
        }
      }

      posting.updatePostingInfoToFirestore().whenComplete(() {
        setState(() => _isLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => HostHomePage(index: 1)));
      });

      CommonFunctions.showSnackBar(context, "Emlak ilanınız başarıyla güncellendi.");
    }
  }




    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.posting == null ? 'Gönderi Ekle' : 'Gönderiyi Güncelle'),
          actions: [
            _isLoading
                ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
                : IconButton(
              icon: const Icon(Icons.upload_file_outlined, color: Colors.white),
              onPressed: () {
                _storePosting();
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "İlanı Yayınla",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Form(
                    key: _formKey,
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //İlan Adı
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: "İlan Adı"),
                            style: const TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                            ),
                            controller: _nameController,
                            validator: (text) {
                              if (text!.isEmpty) {
                                return "Lütfen geçerli bir isim girin.";
                              }
                              return null;
                            },
                          ),

                          //Dropdown
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Emlak Tipi",
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.grey[900],
                                  items: _propertyTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    _propertyTypeChosen = value;
                                    setState(() {});
                                  },
                                  isExpanded: true,
                                  value: _propertyTypeChosen,
                                  hint: const Text(
                                    "Mülk türünü seçin",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white70),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Fiyat
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    decoration:
                                    const InputDecoration(labelText: "Fiyat"),
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      color: Colors.white,
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _priceController,
                                    validator: (text) {
                                      if (text!.isEmpty) {
                                        return "Lütfen geçerli bir fiyat girin.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding:
                                  EdgeInsets.only(left: 10.0, bottom: 10.0),
                                  child: Text(
                                    " 💵TL / gece",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //Açıklama
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Açıklama"),
                              style: const TextStyle(
                                fontSize: 22.0,
                                color: Colors.white,
                              ),
                              controller: _descriptionController,
                              maxLines: 3,
                              minLines: 1,
                              validator: (text) {
                                if (text!.isEmpty) {
                                  return "Lütfen geçerli bir açıklama girin.";
                                }
                                return null;
                              },
                            ),
                          ),

                          //Adres
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: GestureDetector(
                              onTap: () async {
                                String res = await Navigator.push(context,
                                    MaterialPageRoute(builder: (c) =>
                                        SearchPropertyLocationPage()));
                                if (res == "placeSelected") {
                                  setState(() { //setState içinde mülkün adresini adres metin alanında görüntülemek için
                                    _addressController.text = addressOfProperty;
                                    _cityController.text = cityOfProperty;
                                    _countryController.text = countryOfProperty;
                                  });
                                }
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: _addressController,
                                maxLines: 3,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white70,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Adres",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  disabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey)
                                  ),
                                ),
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return "Lütfen geçerli bir adres girin.";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          //Yatak Sayısı
                          const Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Text(
                              'Yatak Sayısı',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          FacilitiesWidget(
                            type: 'Tek/Çift Kişilik',
                            startValue: _beds!['küçük']!,
                            decreaseValue: () {
                              _beds!['küçük'] = (_beds!['küçük']! - 1).clamp(0,
                                  50); //azalış-artış durumu olduğundan bir sayı ile sınırlandırmayı unutma.
                            },
                            increaseValue: () {
                              _beds!['küçük'] = _beds!['küçük']! + 1;
                            },
                          ),
                          FacilitiesWidget(
                            type: 'Çift',
                            startValue: _beds!['orta']!,
                            decreaseValue: () {
                              _beds!['orta'] =
                                  (_beds!['orta']! - 1).clamp(0, 50);
                            },
                            increaseValue: () {
                              _beds!['orta'] = _beds!['orta']! + 1;
                            },
                          ),
                          FacilitiesWidget(
                            type: 'Kraliçe/Kral',
                            startValue: _beds!['büyük']!,
                            decreaseValue: () {
                              _beds!['büyük'] =
                                  (_beds!['büyük']! - 1).clamp(0, 50);
                            },
                            increaseValue: () {
                              _beds!['büyük'] = _beds!['büyük']! + 1;
                            },
                          ),

                          SizedBox(height: 16,),


                          //Banyo Sayısı
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              'Bathrooms',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          FacilitiesWidget(
                            type: 'Tam',
                            startValue: _bathrooms!['tam']!,
                            decreaseValue: () {
                              _bathrooms!['tam'] =
                                  (_bathrooms!['tam']! - 1).clamp(0, 50);
                            },
                            increaseValue: () {
                              _bathrooms!['tam'] = _bathrooms!['tam']! + 1;
                            },
                          ),
                          FacilitiesWidget(
                            type: 'Yarım',
                            startValue: _bathrooms!['yarım']!,
                            decreaseValue: () {
                              _bathrooms!['yarım'] =
                                  (_bathrooms!['yarım']! - 1).clamp(0, 50);
                            },
                            increaseValue: () {
                              _bathrooms!['yarım'] = _bathrooms!['yarım']! + 1;
                            },
                          ),

                          //Olanaklar
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Olanaklar (virgülle ayrılmış)"),
                              style: const TextStyle(
                                fontSize: 22.0,
                                color: Colors.white,
                              ),
                              controller: _amenitiesController,
                              validator: (text) {
                                if (text!.isEmpty) {
                                  return "Please enter valid amenities";
                                }
                                return null;
                              },
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),

                          //Fotoğraflar
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              'Fotoğraflar',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _images!.length + 1,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 25,
                              crossAxisSpacing: 25,
                              childAspectRatio: 3 / 2,
                            ),
                            itemBuilder: (context, index) {
                              if (index == _images!.length) {
                                return Container(
                                  color: Colors.grey[900],
                                  child: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    onPressed: () {
                                      _selectImage(-1);
                                    },
                                  ),
                                );
                              }
                              return MaterialButton(
                                onPressed: () {},
                                child: Image(
                                  image: _images![index],
                                  fit: BoxFit.fill,
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
        ),
      );
    }
  }

