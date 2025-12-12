//CS50 İÇİN YAPTIĞIM STOK TAKİP PROGRAMI
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stok Takip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProductScreen(),
    );
  }
}

class Product {
  int? id;
  String name;
  String category;
  int quantity;
  int minQuantity;
  double price;
  String? notes;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.price,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'price': price,
      'notes': notes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      minQuantity: map['minQuantity'] as int,
      price: (map['price'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }
}



class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'products.db');
    print("DEBUG: DB path = $path");

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print("DEBUG: Veritabanı oluşturuluyor...");
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        minQuantity INTEGER NOT NULL,
        price REAL NOT NULL,
        notes TEXT
      )
    ''');
    print("DEBUG: products tablosu oluşturuldu");
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final id = await db.insert('products', product.toMap());
    print("DEBUG: insertProduct -> id=$id, name=${product.name}");
    return id;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('products', orderBy: 'id ASC');

    print("DEBUG: getAllProducts -> ${maps.length} kayıt var");
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    print("DEBUG: deleteProduct -> id=$id");
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //ÜRÜN GÜNCELLEME
  Future<int> updateProduct(Product product) async {
    final db = await database;
    print("DEBUG: updateProduct -> id=${product.id}, name=${product.name}");
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
}


class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<Product> _products = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadProductsFromDb();
  }

  Future<void> _loadProductsFromDb() async {
    print("DEBUG: _loadProductsFromDb çağrıldı");
    final productsFromDb = await DatabaseHelper.instance.getAllProducts();
    print("DEBUG: DB'den gelen ürün sayısı = ${productsFromDb.length}");

    setState(() {
      _products
        ..clear()
        ..addAll(productsFromDb);
    });
  }

  Future<void> _confirmDelete(int index) async {
    final product = _products[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content: Text('"${product.name}" adlı ürünü silmek istiyor musun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      if (product.id != null) {
        print("DEBUG: DB'den siliniyor, id=${product.id}");
        await DatabaseHelper.instance.deleteProduct(product.id!);
      }

      setState(() {
        print("DEBUG: Listeden siliniyor, index=$index");
        _products.removeAt(index);
      });
    }
  }

  Future<void> _goToAddProductScreen() async {
    print("DEBUG: AddProductScreen'e gidiliyor...");
    final newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );

    if (newProduct == null) {
      print("DEBUG: AddProductScreen'den ürün tekrar dene dostum. (null)");
      return;
    }

    print("DEBUG: Yeni ürün geldi: ${newProduct.name}");

    try {
      final id = await DatabaseHelper.instance.insertProduct(newProduct);
      newProduct.id = id;
      print("DEBUG: Ürün DB'ye kaydedildi, id=$id");

      //  DB'den tekrar yükle
      await _loadProductsFromDb();

      setState(() {
        _searchText = ''; // aramayı sıfırla
      });
    } catch (e) {
      print("HATA: insertProduct sırasında hata oluştu: $e");
    }
  }

  // ÜRÜN DÜZENLEME EKRANI BURADA
  Future<void> _goToEditProductScreen(Product product) async {
    print("DEBUG: EditProductScreen'e gidiliyor... id=${product.id}");
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(product: product),
      ),
    );

    if (updatedProduct == null) {
      print("DEBUG: EditProductScreen'den ürün gelmedi (null)");
      return;
    }

    // id boş gelirse, eski id'yi koru
    updatedProduct.id ??= product.id;

    try {
      await DatabaseHelper.instance.updateProduct(updatedProduct);
      print("DEBUG: Ürün güncellendi, id=${updatedProduct.id}");

      await _loadProductsFromDb();
      setState(() {
        _searchText = '';
      });
    } catch (e) {
      print("HATA: updateProduct sırasında hata oluştu: $e");
    }
  }

  //PDF 
  Future<void> _exportToPdf() async {
    print("DEBUG: PDF oluşturma başladı");
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Stok Listesi',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['ID', 'Ürün', 'Kategori', 'Stok', 'Min', 'Fiyat'],
            data: _products.map((p) {
              return [
                p.id?.toString() ?? '-',
                p.name,
                p.category,
                p.quantity.toString(),
                p.minQuantity.toString(),
                '${p.price.toStringAsFixed(2)} ₺',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
    print("DEBUG: PDF oluşturma bitti");
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) {
      if (_searchText.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchText);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Takip"),
        actions: [
          // PDF Buton Kısmı
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Oluştur',
            onPressed: _products.isEmpty ? null : _exportToPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // ARAMA KUTUSU 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Ürün ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                  print("DEBUG: Arama metni = $_searchText");
                });
              },
            ),
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text('Kayıtlı ürün bulunamadı'),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isCritical =
                          product.quantity <= product.minQuantity;

                      return ListTile(
                        leading: Icon(
                          Icons.inventory_2,
                          color: isCritical ? Colors.red : Colors.green,
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          "Stok: ${product.quantity} | Minimum: ${product.minQuantity}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${product.price} ₺"),
                            const SizedBox(width: 8),

                            // DÜZENLEME BUTONU BU KISMA DİKKAT ET SONRA DEĞİŞTİREBİLEBİLİR.
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final originalIndex =
                                    _products.indexOf(product);
                                if (originalIndex != -1) {
                                  _goToEditProductScreen(
                                      _products[originalIndex]);
                                }
                              },
                            ),

                            // MEVCUT SİL BUTONU
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final originalIndex =
                                    _products.indexOf(product);
                                if (originalIndex != -1) {
                                  _confirmDelete(originalIndex);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddProductScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}



class AddProductScreen extends StatefulWidget {
  //  Düzenleme için ürün
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak alanları doldur burada alanlar öncekiyle aynı olması lazım.
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _categoryController.text = p.category;
      _quantityController.text = p.quantity.toString();
      _minQuantityController.text = p.minQuantity.toString();
      _priceController.text = p.price.toStringAsFixed(2);
      _notesController.text = p.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      print("DEBUG: Form geçersiz, kayıt yapılmadı");
      return;
    }

    final quantity = int.parse(_quantityController.text.trim());
    final minQuantity = int.parse(_minQuantityController.text.trim());
    final price =
        double.parse(_priceController.text.trim().replaceAll(',', '.'));

    final product = Product(
      // düzenlemede id’yi koru
      id: widget.product?.id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: quantity,
      minQuantity: minQuantity,
      price: price,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    print("DEBUG: _saveProduct -> ${product.name}");
    Navigator.of(context).pop(product);
  }
//TEKRAR GÖZDEN GEÇİREBİLİRİM.
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen ürün adını girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen kategori girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration:
                    const InputDecoration(labelText: 'Stok Miktarı'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      int.tryParse(value.trim()) == null) {
                    return 'Geçerli bir stok miktarı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minQuantityController,
                decoration:
                    const InputDecoration(labelText: 'Minimum Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      int.tryParse(value.trim()) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      double.tryParse(
                              value.trim().replaceAll(',', '.')) ==
                          null) {
                    return 'Geçerli bir fiyat girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar (isteğe bağlı)',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(isEdit ? 'Güncelle' : 'Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
