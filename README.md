# Convenience Store Operational Efficiency Report  
**Tên dự án**: Báo cáo Phân tích Vận hành Chuỗi Cửa hàng tiện lợi 7-Eleven  
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
### 2.2. Thiết lập Data Warehouse & Xử lý truy vấn
- **Khởi tạo Schema & Nạp dữ liệu (Data Ingestion)**: Khởi tạo cấu trúc các bảng Dim và Fact. Xử lý nạp dữ liệu từ file tĩnh vào hệ quản trị cơ sở dữ liệu.
- **Thiết lập Mô hình dữ liệu (Data Modeling)**: Khai báo các Ràng buộc toàn vẹn (Integrity Constraints) thông qua Khóa chính (Primary Key) và Khóa ngoại (Foreign Key), thiết lập Relationship nối bảng Fact với các bảng Dim theo cấu trúc Star Schema.
- **Khởi tạo Analytical Views**: Viết các truy vấn SQL để giải quyết trước các câu hỏi phân tích phức tạp, tối ưu hóa hiệu năng cho tầng Visualization. Dưới đây là đoạn script khởi tạo View chuyên biệt để bóc tách ma trận doanh thu của các tổ hợp sản phẩm (Top Combo):
```sql
CREATE VIEW vw_product_combo AS
SELECT 
	p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(DISTINCT a.transaction_id) AS order_count,
    SUM(a.gross_amount - a.discount_amount
		+ b.gross_amount - b.discount_amount) AS revenue
FROM fact_transaction a
JOIN fact_transaction b
	ON a.transaction_id = b.transaction_id
JOIN dim_product p1
	ON a.product_id = p1.product_id
JOIN dim_product p2
	ON b.product_id = p2.product_id
WHERE a.product_id < b.product_id
GROUP BY product_1, product_2
ORDER BY order_count DESC;
```
## Giai đoạn 3 - Trực quan hóa & DAX trên Power BI
### 3.1. Tích hợp & Khởi tạo mô hình (Data Integration & Modeling)
- Thiết lập kết nối luồng dữ liệu trực tiếp từ hệ quản trị MySQL vào Power BI.
- Kiểm trả các mối quan hệ giữa các bảng Dimension và Fact.
### 3.2. Xây dựng hệ thống chỉ số động (Dynamic DAX Measures)
**1. Nhóm chỉ số Hiệu suất & Giỏ hàng (Efficiency & Basket Measures)**
- **Average Order Value (AOV)**: Giá trị đơn hàng trung bình  
```dax
AOV = 
AVERAGEX( 
    VALUES('7_eleven fact_transaction'[transaction_id]), 
    CALCULATE(SUM('7_eleven fact_transaction'[amount]))
	)
```
- **Store Attach Rate**: Số lượng sản phẩm trung bình trên một hóa đơn
```dax
Store Attach Rate = 
DIVIDE(
    COUNTROWS(
        FILTER(
            VALUES('7_eleven fact_transaction'[transaction_id]),
            CALCULATE(COUNTROWS('7_eleven fact_transaction')) > 1)),
    DISTINCTCOUNT('7_eleven fact_transaction'[transaction_id])
)
```
- **Sales per Square Meter (Sale/m2)**: Hiệu suất mặt bằng
```dax
Sale/m2 = divide([Total Revenue],sum('7_eleven dim_store'[floor_area_sqm]),0)
``` 
**2. Nhóm chỉ số Tối ưu Vận hành (Operation & Time Intelligence)**
- **Transactions Per Hour (TPH)**: Tốc độ xử lý giao dịch tại các POS
```dax
Transaction Per Hour = 
VAR TotalPeakOrders = CALCULATE(DISTINCTCOUNT('7_eleven fact_transaction'[transaction_id]), '7_eleven fact_transaction'[Is Peak Hour] = 1)
VAR PeakHourCount = 4
RETURN
DIVIDE(TotalPeakOrders, PeakHourCount,0)
```
- **Peak Hour Contribution (%)**: Tỷ trọng doanh thu giờ cao điểm so với toàn thời gian
```dax
Peak Hour Sale % = 
VAR TotalSales = [Total Revenue]
VAR PeakSales = CALCULATE([Total Revenue],'7_eleven fact_transaction'[Is Peak Hour] = 1)
RETURN
DIVIDE(PeakSales,TotalSales,0)
```
**3. Nhóm chỉ số Quản trị Ngành hàng & Rủi ro (Category & Wastage)**
- **Category Contribution (%)**: Tỷ trọng đóng góp của từng nhóm hàng (Food, Beverage, Snack)
```dax
Normalized % Avg Cate = 
DIVIDE([Total Revenue],[AVG Category],0)
```
- **Wastage Rate (%)**: Tỷ lệ hàng hủy
```dax
Wastage Rate = DIVIDE([Total Wastage],[Total Quantity])
```
### 3.3. Tổng quan Dashboard & Phân tích chi tiết
**Page 1 - Overview**
- **Overview**: Nhìn tổng thể năm 2025, hệ thống ghi nhận sự tăng trưởng ổn định về quy mô khách hàng nhưng đang gặp thách thức trong việc tối ưu giá trị trên từng giỏ hàng.  

![description](https://github.com/2056090185-spec/Convenience-Store-Operational-Efficiency-Report-/blob/main/Convenience%20Store%20Operational%20Efficiency%20Report/Page%201%20-%20Overview.png)

- **Tends**:  
▪️Phân tích xu hướng theo thời gian, doanh thu toàn chuỗi bùng nổ vào tháng 7 – thời điểm vàng của mùa sản xuất điểm cao – nhưng lại sụt giảm bất thường vào tháng 10, có thể đến từ sự thay đổi về quy mô nhân sự hoặc lịch trình làm việc tại các nhà máy lớn như Intel hay Samsung.  
▪️Tỷ lệ hủy hàng (Wastage) duy trì ở mức 2% là một con số an toàn, nhưng cấu trúc nguyên nhân lại cho thấy sự bất ổn. Cụ thể, lỗi hàng hết hạn (Expired) chiếm tỷ trọng áp đảo, đặc biệt tăng vọt vào tháng 4 và tháng 5 dù đây không phải là các tháng doanh thu cao nhất. Đây là điểm bất thường rõ rệt, ám chỉ sự sai lệch trong công tác dự báo cầu và định mức nhập hàng đầu vào trong giai đoạn quý 2.

- **Deep-dive**: Doanh thu tập trung gần như tuyệt đối vào khung giờ 7:00 - 12:00 sáng, với điểm tựa là nhóm sản phẩm Ready-to-eat (RTE) đóng góp tới 69M và Cà phê sữa đá. Tuy nhiên, sự phụ thuộc quá lớn vào một khung giờ và một nhóm sản phẩm RTE cũng tạo ra áp lực cho nhân sự trực ca sáng và rủi ro hủy hàng nếu không tiêu thụ hết trước cuối ngày.

- **Action**:  
**[1]** Đề xuất triển khai các gói Combo chiến lược (ví dụ: Cà phê + Bánh mì/Sandwich) tập trung vào khung giờ sáng để đẩy giá trị giỏ hàng lên mức mục tiêu 90K  
**[2]** Về mặt vận hành, quản lý khu vực cần điều phối lại ca làm việc, dồn 80% nguồn lực phục vụ vào "điểm nghẽn" 6:00 - 9:00 sáng và thực hiện công tác chuẩn bị hàng (Pre-prep) cho các món Best-seller trước giờ mở cửa cao điểm.  
**[3]** Cần điều chỉnh lại thuật toán đặt hàng cho nhóm RTE vào giai đoạn tháng 4 và tháng 10 để giảm thiểu tỷ lệ Expired.  
**[4]** Chạy chương trình "Happy Hour" cho nhóm hàng RTE sẽ để giải phóng tồn kho, vừa bảo vệ biên lợi nhuận, vừa giảm thiểu rác thải thực phẩm.
  
#### 1. Cơ cấu danh mục & Quản trị chống đứt hàng (Assortment & OOS Management)
- **Insight**: "Ready-to-eat" (69M) và "Coffee" (29M) là hai trụ cột doanh thu chính. Ở cấp độ SKU, "Cà Phê Sữa Đá" là sản phẩm dẫn đầu áp đảo (chiếm gần 30M)
- **Action**: Ưu tiên 100% diện tích trung bày 

**Page 2 - Basket & Operation Deep Dive**
- **Overview**: Số liệu ghi nhận khung giờ cao điểm đóng góp tới 33.2% tổng doanh thu, với hiệu suất phục vụ cực cao đạt trung bình 343 giao dịch/giờ. Tuy nhiên, một chỉ số "đau lòng" xuất hiện: AOV giờ cao điểm (71.14K) thấp hơn đáng kể so với AOV trung bình cả ngày (82.18K). Khách hàng ghé cửa hàng vào giờ cao điểm chủ yếu là công nhân viên đang vội, họ mua nhanh – mua ít, dẫn đến việc chúng ta đang "bán sức" phục vụ số lượng lớn nhưng giá trị thu về trên mỗi khách lại chưa tối ưu.

![description](https://github.com/2056090185-spec/Convenience-Store-Operational-Efficiency-Report-/blob/main/Convenience%20Store%20Operational%20Efficiency%20Report/Page%202%20-%20Basket%20%26%20Operation%20Deep%20Dive.png) 

- **Tends**: Zoom in vào Basket Size Distribution, ghi nhận 71.12% khách hàng chỉ mua duy nhất 1 sản phẩm trong một đơn hàng, đây được xem là "nút thắt" khiến doanh thu không thể bùng nổ. Trong khi đó, nhóm khách hàng mua từ 4 món trở lên chỉ chiếm một tỷ trọng rất nhỏ nhưng lại đóng góp tới 42.56% tổng giá trị doanh thu. Xu hướng này cho thấy chúng ta đang bỏ lỡ cơ hội Cross-sell cực lớn ngay tại quầy kệ khi khách hàng đang trong trạng thái "vội vã".

- **Deep-dive**:  
▪️ Ma trận Cross-Sell chỉ ra Cà phê sữa đá là "mặt hàng mồi" (Anchor Product) xuất sắc nhất. Nó có xác suất đi kèm với Bánh bao nhân thịt (25.3%) và Bánh mì thịt nguội (24.4%) rất cao.  
▪️Biểu đồ Top Combo Performance cho thấy sự kết hợp giữa Cà phê sữa đá + Sữa tươi Vinamilk đang dẫn đầu về cả doanh thu và số lượng đơn. Điều này khá thú vị, có thể khách hàng mua giúp đồng nghiệp hoặc đây là thói quen tiêu dùng "đồ uống kép" tại khu vực này.  
▪️Khung giờ 7:00 - 9:00 sáng ghi nhận sự cộng hưởng tuyệt vời giữa Coffee (24%) và Ready-to-eat (21.2%). Đây vùng cần khai thác sâu.

- **Action**:  
**[1]** Kéo 10-15% lượng khách từ nhóm "1 item" sang nhóm "2 items". Đặt các kệ line-up ngay hàng chờ thanh toán với các sản phẩm dễ nhặt như sandwich, bánh ngọt đã được đóng gói sẵn.  
**[2]** Chạy chương trình Combo cố định: "Cà phê + Bánh mì/Bánh bao" với một mã SKU riêng trên hệ thống POS. Việc này vừa giúp nhân viên thao tác nhanh (tăng tốc độ phục vụ >343 đơn/giờ), vừa đảm bảo khách hàng mua đúng cặp sản phẩm mang lại doanh thu cao cho cửa hàng.
  
**Page 3 - Store Performance & Benchmark**
- **Overview**:  
▪️Bức tranh tổng thể của 5 cửa hàng trọng điểm tại Khu Công nghệ cao cho thấy một sự ổn định rất cao với doanh thu trung bình mạng lưới đạt 58.79M/cửa hàng. Intel Products Vietnam đang tạm dẫn đầu cuộc đua với 61M, nhưng khoảng cách với cửa hàng đứng cuối (Hutech - 56M) là không quá lớn.  
▪️Store Attach Rate (0.29) — tức trung bình mỗi khách chỉ mua khoảng 1.3 sản phẩm — đang là vấn đề chung mà chưa cửa hàng nào cũng đang gặp phải.

![description](https://github.com/2056090185-spec/Convenience-Store-Operational-Efficiency-Report-/blob/main/Convenience%20Store%20Operational%20Efficiency%20Report/Page%203%20-%20Store%20Performance%20%26%20Benchmark.png)

- **Tends**:  
▪️Nhìn vào ma trận Store Health (AOV vs. Attach Rate), chúng ta thấy một sự phân hóa thú vị: OneHub Saigon đang là "ngôi sao" về hiệu quả với AOV cao nhất hệ thống (~85K) dù Attach Rate cũng chỉ tương đương các bên khác. Ngược lại, Viện Công nghệ cao Hutech đang nằm ở vùng đáy của đồ thị với AOV thấp nhất (~80K).    
▪️Trong khi các cửa hàng nhà máy (Intel, Samsung) bắt đầu "nóng" từ 7:00 sáng, thì Hutech lại có cú bùng nổ muộn hơn vào khung 8:00 sáng (đạt 2.5%). Điều này phản ánh rõ nét sự khác biệt giữa giờ vào ca của kỹ sư và giờ lên lớp của sinh viên/giảng viên.  

- **Deep-dive**:  
▪️Dù hiệu suất phục vụ cực kỳ ấn tượng với 343 giao dịch/giờ, nhưng chỉ số Store Attach Rate (0.29) — tức là chưa tới 1.3 sản phẩm trên mỗi hóa đơn — chính là nguyên nhân trực tiếp khiến AOV sụt giảm dù lượng đơn hàng tăng mạnh.  
▪️Sự phân hóa giữa các store rất rõ nét: trong khi OneHub Saigon đang tối ưu hóa giá trị đơn hàng rất tốt (AOV cao nhất hệ thống), thì Samsung SEHC dù có tỷ trọng bán hàng RTE dẫn đầu (5.4%) nhưng lại đang "bỏ quên" nhóm Coffee, dẫn đến việc Attach Rate không thể bứt phá.  

- **Action**: Lấy OneHub làm hình mẫu để đào tạo lại kỹ năng Cross-sell cho nhân sự tại Samsung và Hutech, đặc biệt là cách mời thêm đồ uống (Coffee/RTD Tea) đi kèm với đồ ăn nóng.

# 6. Chiến lược hành động dựa trên dữ liệu
## 1. Khung giờ nào cần tăng cường mật độ nhân viên?  
- **Câu trả lời từ Dashboard**:  
▪️Giờ cao điểm sáng (7:00 - 09:00): Đây là khung giờ chiếm 33.2% doanh thu. Đặc biệt, Page 2 chỉ ra mật độ giao dịch lên tới 343 đơn/giờ.    
▪️Nút thắt ăn trưa (10:00 - 12:30): Page 1 và 2 xác nhận đây là điểm nghẽn (Bottleneck).  
- **Hành động cụ thể**: Quản lý không cần tăng nhân sự cả ngày. Chỉ cần điều phối "Ca gãy" (Split shift) hoặc dồn 80% nhân sự vào đúng 2 khung giờ trên. Tại điểm nghẽn 12:00, cần ít nhất 1 nhân viên chuyên trách "đóng gói sẵn" các món RTE phổ biến để khách chỉ việc "cầm và thanh toán", giảm tối đa thời gian chờ tại quầy.

## 2. Mặt hàng nào cần châm thêm (restock) trước 11:00 sáng?
- **Câu trả lời từ Dashboard**: Page 1 (Top Products) và Page 2 (Heatmap) đã chỉ ra danh sách ưu tiên:  
▪️Nhóm Ready-to-eat (RTE): Cơm nắm, Bánh bao nhân thịt, Sandwich trứng.  
▪️Nhóm Instant Food: Mì ly hải sản, Xúc xích đức.  
▪️Nguyên liệu pha chế: Sữa tươi Vinamilk (vì đây là món đi kèm "Top Combo" với Cà phê).  
- **Hành động cụ thể**: Nhân viên kiểm kho phải hoàn tất việc châm hàng cho nhóm này chậm nhất là 10:45. Dữ liệu cho thấy sau 11:00 là biểu đồ doanh thu bắt đầu tăng, nếu đợi đến lúc đó mới châm hàng sẽ gây ra tình trạng "đứt hàng" (Out-of-stock) ngay lúc khách đông nhất.

## 3. Sản phẩm nào thực sự hiệu quả để ưu tiên trưng bày?
- **Câu trả lời từ Dashboard**: Nhìn vào Ma trận bổ trợ (Cross-sell) ở Page 2 và Tỷ trọng danh mục ở Page 3, cho thấy:  
▪️Vị trí "Vàng" (ngang tầm mắt/quầy thu ngân): Dành cho Cà phê sữa đá và Bánh mì thịt nguội. Ma trận Cross-sell cho thấy 2 món này có lực kéo cực lớn (xác suất mua kèm >24%).  
▪️Nhóm tiềm năng (Private Label): Dựa trên Page 1, nhóm RTE (thường là hàng nhãn riêng của 7-Eleven) đóng góp tới 69M. Cần ưu tiên diện tích kệ lớn hơn cho nhóm này vì nó vừa kéo traffic, vừa có biên lợi nhuận tốt.  
- **Hành động cụ thể**: Tái cấu trúc lại Planogram (sơ đồ trưng bày). Loại bỏ bớt diện tích của các nhóm có hiệu suất thấp (như Confectionery - chỉ chiếm 3.3%) để nhường chỗ cho nhóm Instant Food (12.7%) và RTE.
---
# Tổng kết & Đánh giá  
## Kinh nghiệm
## Hạn chế
