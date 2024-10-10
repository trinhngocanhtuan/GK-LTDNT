import 'package:flutter/material.dart'; // Nhập thư viện Flutter để xây dựng giao diện người dùng
import 'package:firebase_database/firebase_database.dart'; // Nhập thư viện Firebase Database để sử dụng cơ sở dữ liệu Firebase

// Định nghĩa lớp Product để mô tả sản phẩm
class Product {
  String name; // Tên
  String category; // Loại
  int price; // Giá
  String imageUrl; // URL hình ảnh

  // Constructor để khởi tạo các thuộc tính của sản phẩm mọi thứ bắt buộc hết
  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  // Hàm chuyển đổi đối tượng Product thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name, // Đặt tên sản phẩm
      'category': category, // Đặt loại sản phẩm
      'price': price, // Đặt giá sản phẩm
      'imageUrl': imageUrl, // Đặt URL hình ảnh
    };
  }
}

// Lớp HomePage kế thừa StatefulWidget để có thể thay đổi trạng thái
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Tạo trạng thái cho trang chính
}

// Lớp trạng thái của HomePage
class _HomePageState extends State<HomePage> {
  // Các biến điều khiển để lấy dữ liệu từ các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // Danh sách các sản phẩm
  List<Product> _products = [];
  // Khởi tạo đường dẫn tới cơ sở dữ liệu Firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('products');

  // Phương thức xây dựng giao diện người dùng
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dữ liệu sản phẩm'), // Tiêu đề của ứng dụng
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Khoảng cách giữa các thành phần trong body
        child: Column(
          children: [
            // Gọi hàm để tạo các trường nhập liệu
            _buildTextField(_nameController, 'Tên sản phẩm'),
            _buildTextField(_categoryController, 'Loại sản phẩm'),
            _buildTextField(_priceController, 'Giá sản phẩm', keyboardType: TextInputType.number),
            _buildTextField(_imageController, 'URL hình ảnh'),
            SizedBox(height: 10), // Khoảng cách giữa nút thêm sản phẩm và các trường nhập liệu
            ElevatedButton(
              onPressed: _addProduct, // Gọi hàm thêm sản phẩm khi nhấn nút
              child: Text('THÊM SẢN PHẨM'), // Văn bản trên nút
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Màu nền của nút
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Padding cho nút
              ),
            ),
            SizedBox(height: 20), // Khoảng cách giữa nút và danh sách sản phẩm
            _buildProductList(), // Gọi hàm để hiển thị danh sách sản phẩm
          ],
        ),
      ),
    );
  }

  // Hàm để xây dựng trường nhập liệu
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10), // Khoảng cách dưới trường nhập liệu
      child: TextField(
        controller: controller, // Liên kết trường nhập liệu với điều khiển
        keyboardType: keyboardType, // Thiết lập kiểu bàn phím (nếu cần)
        decoration: InputDecoration(
          labelText: label, // Nhãn cho trường nhập liệu
          border: OutlineInputBorder(), // Đường viền cho trường nhập liệu
        ),
      ),
    );
  }

  // Hàm để thêm sản phẩm vào danh sách và lưu lên Firebase
  void _addProduct() {
    final String name = _nameController.text;
    final String category = _categoryController.text;
    final int price = int.tryParse(_priceController.text) ?? 0;
    final String imageUrl = _imageController.text;

    // Kiểm tra nếu bất kỳ trường nào trống hoặc không hợp lệ
    if (name.isEmpty || category.isEmpty || price <= 0 || imageUrl.isEmpty) {
      // Hiển thị thông báo nếu thông tin không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng điền đầy đủ thông tin sản phẩm')));
      return; // Kết thúc hàm nếu thông tin không hợp lệ
    }

    // Tạo sản phẩm mới
    final Product newProduct = Product(
      name: name, // Đặt tên sản phẩm
      category: category,
      price: price,
      imageUrl: imageUrl,
    );

    // Lưu sản phẩm vào Firebase
    _dbRef.push().set(newProduct.toMap()).then((_) {
      setState(() { // Cập nhật trạng thái để hiển thị lại giao diện
        _products.add(newProduct); // Thêm sản phẩm mới vào danh sách sản phẩm
      });

      // Xóa dữ liệu trong các trường nhập sau khi thêm sản phẩm
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _imageController.clear();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thêm sản phẩm thành công')));
    }).catchError((error) {
      // Hiển thị thông báo thất bại nếu có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thêm sản phẩm thất bại: $error')));
    });
  }

  // Hàm để xây dựng danh sách sản phẩm
  Widget _buildProductList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _products.length, // Số lượng sản phẩm trong danh sách
        itemBuilder: (context, index) { // Hàm để xây dựng từng mục trong danh sách
          final product = _products[index]; // Lấy sản phẩm tại vị trí index
          return _buildProductItem(product, index); // Gọi hàm để xây dựng mục sản phẩm
        },
      ),
    );
  }

  // Hàm để xây dựng một mục sản phẩm
  Widget _buildProductItem(Product product, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10), // Khoảng cách giữa các thẻ sản phẩm
      child: ListTile(
        leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover), // Hiển thị hình ảnh sản phẩm
        title: Text('Tên sp: ${product.name}'), // Hiển thị tên sản phẩm
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Canh trái cho các mục con
          children: [
            Text('Giá sp: ${product.price}'), // Hiển thị giá sản phẩm
            Text('Loại sp: ${product.category}'), // Hiển thị loại sản phẩm
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Chiều rộng tối thiểu cho hàng
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.yellow), // Nút chỉnh sửa
              onPressed: () => _editProduct(product, index), // Gọi hàm chỉnh sửa sản phẩm
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red), // Nút xóa
              onPressed: () => _deleteProduct(index), // Gọi hàm xóa sản phẩm
            ),
          ],
        ),
      ),
    );
  }

  // Hàm để chỉnh sửa sản phẩm
  void _editProduct(Product product, int index) {
    // Đặt dữ liệu vào các trường nhập liệu
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _priceController.text = product.price.toString();
    _imageController.text = product.imageUrl;

    // Hiển thị hộp thoại để chỉnh sửa sản phẩm
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa sản phẩm'), // Tiêu đề hộp thoại
          content: Column(
            mainAxisSize: MainAxisSize.min, // Kích thước tối thiểu cho cột
            children: [
              // Gọi hàm để tạo các trường nhập liệu cho chỉnh sửa
              _buildTextField(_nameController, 'Tên sản phẩm'),
              _buildTextField(_categoryController, 'Loại sản phẩm'),
              _buildTextField(_priceController, 'Giá sản phẩm', keyboardType: TextInputType.number),
              _buildTextField(_imageController, 'URL hình ảnh'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại nếu nhấn Hủy
              },
              child: Text('Hủy'), // Văn bản cho nút Hủy
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Cập nhật danh sách sản phẩm với thông tin đã chỉnh sửa
                  _products[index] = Product(
                    name: _nameController.text,
                    category: _categoryController.text,
                    price: int.tryParse(_priceController.text) ?? 0,
                    imageUrl: _imageController.text,
                  );
                });
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi lưu
                // Xóa dữ liệu trong các trường nhập sau khi lưu
                _nameController.clear();
                _categoryController.clear();
                _priceController.clear();
                _imageController.clear();
              },
              child: Text('Lưu'), // Văn bản cho nút Lưu
            ),
          ],
        );
      },
    );
  }

  // Hàm để xóa sản phẩm
  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index); // Xóa sản phẩm tại vị trí index khỏi danh sách
    });
  }
}