# Hướng dẫn thiết lập Strapi Backend

## 1. Cài đặt Strapi

### Yêu cầu hệ thống:
- Node.js (version 16 hoặc cao hơn)
- npm hoặc yarn

### Cài đặt Strapi:
```bash
npx create-strapi-app@latest restaurant-menu-backend
cd restaurant-menu-backend
npm run develop
```

## 2. Tạo Content Types

### Tạo Category Content Type:

1. Vào **Content-Type Builder** trong admin panel
2. Click **Create new collection type**
3. Tạo collection type với tên **Category**
4. Thêm field:
   - **name** (Text, Required, Unique)

### Tạo Dish Content Type:

1. Vào **Content-Type Builder**
2. Click **Create new collection type**
3. Tạo collection type với tên **Dish**
4. Thêm các fields:
   - **name** (Text, Required)
   - **description** (Text, Long text)
   - **price** (Number, Decimal, Required)
   - **image** (Media, Single media)
   - **category** (Relation, Many-to-one với Category)

## 3. Cấu hình Permissions

1. Vào **Settings > Users & Permissions plugin > Roles**
2. Chọn **Public** role
3. Cấp quyền cho Category và Dish:
   - **find** (để đọc danh sách)
   - **findOne** (để đọc chi tiết)
   - **create** (để tạo mới)
   - **update** (để cập nhật)
   - **delete** (để xóa)

## 4. Tạo dữ liệu mẫu

### Tạo Categories:
1. Vào **Content Manager > Category**
2. Tạo các categories:
   - **Khai vị** (Appetizers)
   - **Món chính** (Main Course)
   - **Tráng miệng** (Desserts)
   - **Đồ uống** (Beverages)

### Tạo Dishes:
1. Vào **Content Manager > Dish**
2. Tạo các món ăn mẫu:

**Khai vị:**
- Gỏi cuốn (Fresh Spring Rolls) - $8.50
- Chả giò (Fried Spring Rolls) - $9.00

**Món chính:**
- Phở bò (Beef Pho) - $15.00
- Cơm tấm (Broken Rice) - $12.00
- Bún chả (Grilled Pork Noodles) - $13.50

**Tráng miệng:**
- Chè ba màu (Three Color Dessert) - $6.00
- Bánh flan (Vietnamese Flan) - $5.50

**Đồ uống:**
- Cà phê sữa đá (Vietnamese Iced Coffee) - $4.00
- Trà đá (Iced Tea) - $3.00

## 5. Cấu hình Media

1. Vào **Settings > Media Library**
2. Đảm bảo **Local upload provider** được cấu hình
3. Upload hình ảnh cho các món ăn

## 6. Cấu hình CORS (nếu cần)

Nếu gặp lỗi CORS, thêm vào file `config/middlewares.js`:

```javascript
module.exports = [
  'strapi::errors',
  {
    name: 'strapi::security',
    config: {
      contentSecurityPolicy: {
        useDefaults: true,
        directives: {
          'connect-src': ["'self'", 'https:'],
          'img-src': ["'self'", 'data:', 'blob:', 'https:'],
          'media-src': ["'self'", 'data:', 'blob:', 'https:'],
          upgradeInsecureRequests: null,
        },
      },
    },
  },
  'strapi::cors',
  'strapi::poweredBy',
  'strapi::logger',
  'strapi::query',
  'strapi::body',
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
];
```

## 7. Khởi chạy Strapi

```bash
npm run develop
```

Strapi sẽ chạy tại: `http://localhost:1337`

## 8. Kiểm tra API

Test API endpoints:
- `GET http://localhost:1337/api/categories` - Lấy danh sách categories
- `GET http://localhost:1337/api/dishes?populate=*` - Lấy danh sách dishes với relations

## Lưu ý quan trọng:

1. **URL trong Flutter app**: Đảm bảo URL trong `lib/services/api_service.dart` trỏ đến đúng Strapi server
2. **Permissions**: Đảm bảo đã cấp đủ quyền cho Public role
3. **Media**: Hình ảnh sẽ được lưu trong thư mục `public/uploads/`
4. **Database**: Strapi sử dụng SQLite mặc định, có thể thay đổi sang PostgreSQL/MySQL cho production 