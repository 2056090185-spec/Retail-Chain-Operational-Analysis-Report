# Retail Chain Operational Analysis Report  
**Tên dự án**: Báo cáo Phân tích Vận hành Chuỗi bán lẻ  
**Công cụ sử dụng**: Excel + MySQL + Power BI  
**Người trình bày**: Võ Thị Thứ Phi

# 1. Tổng quan dự án  
## Mục tiêu:
Xây dựng hệ thống báo cáo phân tích chuyên sâu nhằm tối ưu hóa hiệu quả vận hành thực tế cho chuỗi 7-Eleven tại Khu Công nghệ cao. Dự án tập trung giải quyết 3 yếu tố vận hành:  
- **Peak Hour Optimization**: Tối ưu hóa năng suất giờ cao điểm  
- **Inventory & Wastage Control**: Kiểm soát tồn kho và giảm thiểu tỷ lệ hủy hàng  
- **Category Excellence**: Quản trị danh mục sản phẩm tiềm năng  
## Công cụ:
- **Excel**: Tạo bộ dữ liệu giả lập, mô phỏng dựa trên hành vi tiêu dùng thực tế của nhóm khách hàng đặc thù tại Khu Công nghệ cao.
- **MySQL**: Xây dựng kho dữ liệu, thực hiện quy trình ETL để chuẩn hóa dữ liệu thô và thiết lập các SQL Views tối ưu cho truy vấn báo cáo.				  
- **Power BI**: Thiết kế Dashboard tương tác, áp dụng DAX để tính toán các chỉ số tăng trưởng và trực quan hóa các điểm nghẽn vận hành.

# 2. Bối cảnh & Xác định vấn đề
## Bối cảnh:
Chuỗi cửa hàng tiện lợi 7-Eleven tại Khu Công nghệ cao có một tệp khách hàng đặc thù: Kỹ sư, nhân viên văn phòng và sinh viên. Đặc điểm hành vi của nhóm khách hàng này là nhịp sống nhanh, ưu tiên sự tiện lợi, có khung giờ sinh hoạt cố định và nhu cầu tiêu thụ thực phẩm chế biến sẵn (Ready-to-eat) cực kỳ lớn.
## Vấn đề:
Điểm chung của các cửa hàng này này là có lượng khác hàng tiềm năng lớn, các quản lý cửa hàng/khu vực muốn theo dõi và tối ưu hiệu suất vận hành với 3 nhóm tác động sau:
- **Peak Hour Optimization**: Tình trạng quá tải thường xuyên xảy ra vào giờ nghỉ trưa (12:00 - 12:30) khiến khách hàng phải xếp hàng dài, dẫn đến tỷ lệ rời bỏ (walk-outs) tăng cao. Trong khi đó, vào ca sáng (6:00 - 9:00), nhân viên mất nhiều thời gian tư vấn bán chéo (cross-sell) do chưa có các gói "Combo chiến lược" được đóng gói sẵn.			
- **Inventory & Wastage Control**: Các mặt hàng Best-seller (như cà phê sữa đá, cơm nắm) thường xuyên "cháy hàng" ngay trong giờ cao điểm. Ngược lại, nhóm thực phẩm tươi sống có hạn sử dụng trong ngày (Shelf-life = 1 day) lại ghi nhận tỷ lệ hủy (Wastage Rate) cuối ngày ở mức đáng báo động.	
- **Category Performance**: Diện tích kệ hàng có hạn nhưng việc phân bổ vị trí trưng bày chưa dựa trên dữ liệu hiệu suất ngành hàng. Các sản phẩm mang lại doanh thu tốt (đặc biệt là Hàng nhãn riêng - Private Label) chưa được ưu tiên hiển thị đúng mức so với các sản phẩm thông thường.
## Nhiệm vụ:
Xây dựng một hệ thống báo cáo khai thác trực tiếp từ dữ liệu giao dịch bán hàng. Mục tiêu là cung cấp một góc nhìn tổng quan về sức khỏe vận hành, giúp quản lý cửa hàng/khu vực trả lời được các câu hỏi:
- Khung giờ nào cần tăng cường mật độ nhân viên để giảm tỷ lệ khách rời bỏ (walk-outs)?
- Những mặt hàng nào cần được châm thêm (restock) trước 11:00 sáng để tránh đứt hàng giờ cao điểm?
- Sản phẩm nào thực sự mang lại hiệu quả kinh doanh để ưu tiên vị trí trưng bày trên kệ hàng?

# 3. Các chỉ số đo lường & Mô hình dữ liệu
## Chỉ số đo lường
| Group     | Metric                    | Definition                                      | Note                                                                 |
|----------|--------------------------|------------------------------------------------|----------------------------------------------------------------------|
| Top-line | Total Revenue            | Tổng doanh thu sau giảm giá                    | Đo lường mức độ hoàn thành chỉ tiêu; đánh giá sức khỏe kinh doanh tổng thể |
| Top-line | AOV (Avg Order Value)    | Tổng Doanh thu / Tổng đơn hàng                 | Giá trị đơn hàng trung bình; kiểm tra hiệu quả bán chéo (combo)     |
| Efficiency | Sale/m2                | Tổng Doanh thu / Diện tích sàn (m2)           | Đánh giá hiệu suất mặt bằng; cơ sở quyết định mở rộng hoặc thu hẹp quầy kệ |
| Efficiency | Store Attach Rate      | Tổng số món / Tổng số đơn hàng                | Số món trung bình trên hóa đơn; đo lường mức độ mua thêm của khách hàng |
| Operation | Peak Hour Contrib (%)   | Doanh thu giờ cao điểm / Tổng doanh thu ngày  | Xác định chính xác đỉnh giờ cao điểm để xếp ca nhân sự và điều phối quầy thu ngân |
| Operation | TPH (Transactions/Hr)   | Tổng số Bill / Số giờ trong khung giờ đó      | Mật độ giao dịch theo giờ                                                                     |
| Operation | Wastage Rate            | Giá trị hàng hủy / Giá trị hàng nhập vào      | Tỉ lệ hủy hàng tươi sống (Fresh Food) hoặc hỏng hóc; tối ưu hóa khâu đặt hàng (Ordering) |
| Strategy  | Category Contrib        | Doanh thu Ngành hàng / Tổng doanh thu         | Tỉ trọng doanh thu từng nhóm hàng (Food, Drink); cơ sở để phân bổ diện tích trưng bày |
| Strategy  | Combo Performance       | Số lượng đơn hàng chứa các cặp sản phẩm kết hợp | Đo lường mức độ tiêu thụ các gói bán chéo; tăng tốc độ phục vụ và chốt sale |

## Mô hình dữ liệu
![description](https://github.com/2056090185-spec/Retail-Chain-Operational-Analysis-Report/blob/main/Star%20Schema%20Data%20Modeling.png)

# 5. Quy trình xử lý
## Giai đoạn 1 - Xây dựng & giả lập dữ liệu trên Excel
### Mô phỏng hành vi mua sắm
- **Chân dung khách hàng**: Kỹ sư, Nhân viên văn phòng, Sinh viên
- **Hành vi mua sắm**: có khung giờ sinh hoạt cố định, ưu tiên sự tiện lợi và nhu cầu tiêu thụ thực phẩm chế biến sẵn (Ready-to-eat)
### Tạo bộ dữ liệu
Sử dụng Excel để tạo bộ dữ liệu ngẫu nhiên và phải đảm bảo tính logic từ hành vi mua sắm đã được mô phỏng. Quá trình này sử dụng các nhóm hàm cốt lõi:
- **RANDBETWEEN()**: Tạo lượng giao dịch, số lượng sản phẩm/đơn và gán ngẫu nhiên ID cửa hàng, ID sản phẩm.
- **VLOOKUP**: Truy suất thông tin từ các bảng chiều (Dim) sang bảng sự kiện (Fact).
- **Các hàm logic (IF, IFS)**: Thiết lập trọng số xác suất để ép dòng dữ liệu chạy theo kịch bản hành vi đã định trước.
  
## Giai đoạn 2 - Xử lý & Chuẩn hóa dữ liệu trên MySQL
### 2.1. Ghi chú khám phá dữ liệu
Phân tích sơ bộ (EDA) và chỉ ra các đặc tính (patterns) cốt lõi của bộ dữ liệu:
#### [1] Peak Hour Optimization:
- Doanh thu tập trung vào 7–9h & 10–11h -> hành vi mua “grab & go”
- Cà phê là traffic driver kết hợp bánh mì/sandwich tạo combo chủ lực
- Cần tối ưu vận hành (prep trước, staffing theo giờ) để tránh nghẽn  
#### [2] Tốc độ bán (Morning vs Lunch):
- Buổi sáng thiên về combo nhanh (cà phê + đồ ăn nhẹ)
- Buổi trưa chuyển sang “quick meal” (mì ly, cơm) + nước ngọt đi kèm
- Cần tối ưu layout (đặt gần nhau) và thiết bị (nước nóng, lò vi sóng); xúc xích/snack đóng vai trò cross-sell
#### [3] Category Performance:
- RTE chiếm ~64% → core revenue driver nhưng phụ thuộc vận hành
- Private Label ~42%
- Cần ưu tiên shelf space + combo (RTE + beverage) để tối đa hóa doanh thu
## Giai đoạn 3 - Thiết kế Layout
## Giai đoạn 4 - Trực quan hóa & DAX trên Power BI


