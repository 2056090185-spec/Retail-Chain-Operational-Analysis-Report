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
- **Category Excellence**: Diện tích kệ hàng có hạn nhưng việc phân bổ vị trí trưng bày chưa dựa trên dữ liệu hiệu suất ngành hàng. Các sản phẩm mang lại biên lợi nhuận cao (đặc biệt là Hàng nhãn riêng - Private Label) chưa được ưu tiên hiển thị đúng mức so với các sản phẩm thông thường.
## Nhiệm vụ:
Xây dựng một hệ thống báo cáo khai thác trực tiếp từ dữ liệu giao dịch bán hàng. Mục tiêu là cung cấp một góc nhìn tổng quan về sức khỏe vận hành, giúp quản lý cửa hàng/khu vực trả lời được các câu hỏi:
- Khung giờ nào cần tăng cường mật độ nhân viên để giảm tỷ lệ khách rời bỏ (walk-outs)?
- Những mặt hàng nào cần được châm thêm (restock) trước 11:00 sáng để tránh đứt hàng giờ cao điểm?
- Sản phẩm nào thực sự mang lại hiệu quả kinh doanh để ưu tiên vị trí trưng bày trên kệ hàng?

# 3. Các chỉ số đo lường & Mô hình dữ liệu
## Chỉ số đo lường








